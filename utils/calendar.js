import ICAL from "ical.js";

/**
 * Fetch and parse iCal data from multiple calendar URLs.
 *
 * @param {Array<{label: string, color: string, url: string}>} calendars
 *   Calendar configs, typically loaded from localStorage.
 * @returns {Promise<{events: Array, lastUpdated: string, calendarsProcessed: number}>}
 */
export async function fetchAndParseCalendars(calendars) {
  const allEvents = [];

  for (const calendar of calendars) {
    try {
      const events = await fetchSingleCalendar(calendar);
      allEvents.push(...events);
    } catch (err) {
      console.error(`Error processing calendar "${calendar.label}":`, err);
    }
  }

  // Sort events by start date
  allEvents.sort(
    (a, b) => new Date(a.start).getTime() - new Date(b.start).getTime()
  );

  return {
    events: allEvents,
    lastUpdated: new Date().toISOString(),
    calendarsProcessed: calendars.length,
  };
}

/**
 * Fetch and parse a single iCal calendar URL.
 *
 * @param {{label: string, color: string, url: string}} calendar
 * @returns {Promise<Array>} Parsed calendar events.
 */
async function fetchSingleCalendar(calendar) {
  // Proxy through the server to avoid CORS restrictions
  const proxyUrl = `/api/proxy-ical?url=${encodeURIComponent(calendar.url)}`;
  const response = await fetch(proxyUrl);
  if (!response.ok) {
    console.warn(
      `Failed to fetch calendar "${calendar.label}": ${response.status} ${response.statusText}`
    );
    return [];
  }

  const icalData = await response.text();
  return parseICalData(icalData, calendar);
}

/**
 * Parse raw iCal text into an array of calendar event objects.
 *
 * Handles single events, recurring events with RRULE expansion,
 * recurrence exceptions (modified instances), and EXDATE exclusions.
 *
 * @param {string} icalData  Raw iCal text.
 * @param {{label: string, color: string, url: string}} calendar
 * @returns {Array} Parsed events within the display window.
 */
export function parseICalData(icalData, calendar) {
  const jcalData = ICAL.parse(icalData);
  const comp = new ICAL.Component(jcalData);
  const vevents = comp.getAllSubcomponents("vevent");

  // --- Collect recurrence exceptions (modified instances) ---
  const recurrenceExceptions = new Map();
  for (const vevent of vevents) {
    const recurrenceId = vevent.getFirstPropertyValue("recurrence-id");
    if (recurrenceId) {
      const masterUid = vevent.getFirstPropertyValue("uid");
      if (!recurrenceExceptions.has(masterUid)) {
        recurrenceExceptions.set(masterUid, new Map());
      }
      let recurrenceDate;
      if (
        recurrenceId &&
        typeof recurrenceId === "object" &&
        "toJSDate" in recurrenceId
      ) {
        recurrenceDate = recurrenceId.toJSDate();
      } else if (typeof recurrenceId === "string") {
        recurrenceDate = new Date(recurrenceId);
      } else {
        continue;
      }
      recurrenceExceptions
        .get(masterUid)
        .set(recurrenceDate.getTime(), vevent);
    }
  }

  // --- Date range for expansion ---
  const now = new Date();
  const pastLimit = new Date(now.getTime() - 30 * 24 * 60 * 60 * 1000);
  const futureLimit = new Date(now.getTime() + 90 * 24 * 60 * 60 * 1000);

  const events = [];

  for (const vevent of vevents) {
    // Skip recurrence exceptions – handled inline below
    if (vevent.getFirstPropertyValue("recurrence-id")) continue;

    const event = new ICAL.Event(vevent);

    if (event.isRecurring()) {
      expandRecurringEvent(
        event,
        vevent,
        calendar,
        recurrenceExceptions,
        pastLimit,
        futureLimit,
        events
      );
    } else {
      const startDate = event.startDate.toJSDate();
      if (startDate >= pastLimit && startDate <= futureLimit) {
        events.push(buildEventObject(event, calendar, false));
      }
    }
  }

  return events;
}

// -------- internal helpers --------

function expandRecurringEvent(
  event,
  vevent,
  calendar,
  recurrenceExceptions,
  pastLimit,
  futureLimit,
  events
) {
  // Gather EXDATE exclusions
  const exceptionDates = new Set();
  const exdateProps = vevent.getAllProperties("exdate");
  for (const exdateProp of exdateProps) {
    for (const val of exdateProp.getValues()) {
      let ts;
      if (val && typeof val === "object" && "toJSDate" in val) {
        ts = val.toJSDate().getTime();
      } else if (typeof val === "string") {
        ts = new Date(val).getTime();
      } else {
        continue;
      }
      exceptionDates.add(ts);
    }
  }

  const eventExceptions =
    recurrenceExceptions.get(event.uid) || new Map();

  const iterator = event.iterator();
  let next;
  let count = 0;

  while ((next = iterator.next())) {
    const startDate = next.toJSDate();
    const startTime = startDate.getTime();

    if (startDate > futureLimit) break;
    if (exceptionDates.has(startTime)) continue;

    // Use modified instance if available
    let eventToUse = event;
    if (eventExceptions.has(startTime)) {
      eventToUse = new ICAL.Event(eventExceptions.get(startTime));
    }

    if (startDate >= pastLimit && startDate <= futureLimit) {
      const duration = eventToUse.endDate.subtractDate(eventToUse.startDate);
      const endIcal = next.clone();
      endIcal.addDuration(duration);

      events.push({
        id: `${calendar.label}-${eventToUse.uid}-${startTime}`,
        title: eventToUse.summary,
        start: startDate.toISOString(),
        end: endIcal.toJSDate().toISOString(),
        description: eventToUse.description || "",
        location: eventToUse.location || "",
        calendar: calendar.label,
        color: calendar.color,
        isRecurring: true,
      });
    }

    // Safety valve
    if (++count > 10000) {
      console.warn(
        `Too many occurrences for "${calendar.label}", stopping expansion`
      );
      break;
    }
  }
}

function buildEventObject(event, calendar, isRecurring) {
  return {
    id: `${calendar.label}-${event.uid}`,
    title: event.summary,
    start: event.startDate.toJSDate().toISOString(),
    end: event.endDate.toJSDate().toISOString(),
    description: event.description || "",
    location: event.location || "",
    calendar: calendar.label,
    color: calendar.color,
    isRecurring,
  };
}
