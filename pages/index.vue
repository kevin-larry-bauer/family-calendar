<template>
  <div class="h-screen w-screen bg-gray-900 text-white overflow-hidden">
    <div class="flex h-full">
      <!-- Left Sidebar (25% width) -->
      <div class="w-1/5 bg-gray-800 p-6 flex flex-col">
        <!-- Clock -->
        <div class="mb-8">
          <div class="text-6xl font-light mb-2">{{ currentTime }}</div>
          <div class="text-xl text-gray-300">{{ currentDate }}</div>
        </div>

        <!-- Today's Agenda -->
        <div class="flex-1 overflow-hidden">
          <!-- Day View Time Grid (7am to 10pm) -->
          <div class="relative h-full overflow-y-auto bg-gray-800 rounded-lg">
            <div
              class="absolute left-0 top-0 w-full h-full pointer-events-none"
            >
              <!-- Horizontal line above 7am -->
              <div
                class="absolute left-0 top-0 w-full border-b border-gray-700"
                style="height: 0"
              ></div>
              <div
                v-for="hour in 15"
                :key="hour"
                class="h-[60px] border-b border-gray-700 flex items-start"
              >
                <span
                  class="w-12 text-xs text-gray-400 text-right pr-2 select-none"
                  style="min-width: 3rem"
                  >{{ formatHour(hour + 6) }}</span
                >
              </div>
            </div>
            <div class="relative z-10" style="height: 900px">
              <!-- 15 hours * 60px per hour = 900px -->
              <div
                v-for="event in todayEvents"
                :key="event.id"
                :style="
                  Object.assign({}, getEventStyleDayView(event), {
                    borderLeftColor: event.color || '#60a5fa',
                  })
                "
                class="absolute left-16 right-2 bg-gray-700 rounded-lg border-l-4 py-1 px-2 shadow-md"
                :class="{ 'border-blue-400': !event.color }"
              >
                <div class="font-medium text-xs">
                  {{ event.title }}
                  <span v-if="isAllDayEvent(event)" class="text-xs text-gray-300"> (all day)</span>
                </div>
                <div
                  v-if="!isAllDayEvent(event) && getEventDurationMinutes(event) >= 45"
                  class="text-xs text-gray-300"
                >
                  {{ formatTime(event.start) }} - {{ formatTime(event.end) }}
                </div>
                <div
                  v-if="event.location"
                  class="text-xs text-gray-400 flex items-center"
                >
                  <span class="mr-1">📍</span>
                  {{ event.location }}
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Right Main Area (75% width) -->
      <div class="flex-1 p-6">
        <div class="h-full">
          <!-- Header -->
          <div class="mb-6">
            <div class="flex items-center justify-between">
              <h1 class="text-4xl font-light">
                Family Calendar: {{ weekRangeText }}
              </h1>
              <div class="text-right">
                <div
                  v-if="pending"
                  class="flex items-center text-blue-400 text-sm"
                >
                  <div
                    class="animate-spin rounded-full h-4 w-4 border-b-2 border-blue-400 mr-2"
                  ></div>
                  Updating...
                </div>
                <div
                  v-else-if="data?.lastUpdated"
                  class="text-gray-400 text-sm"
                >
                  Last updated: {{ formatLastUpdated(data.lastUpdated) }}
                </div>
              </div>
            </div>
          </div>

          <!-- Two-Week Calendar Grid -->
          <div class="grid grid-cols-7 gap-2 h-[80vh]">
            <!-- Day Headers -->
            <div
              v-for="day in dayHeaders"
              :key="day"
              class="text-center text-gray-300 font-medium py-2 text-lg"
            >
              {{ day }}
            </div>

            <!-- Calendar Days -->
            <div
              v-for="day in calendarDays"
              :key="day.date"
              class="rounded-lg p-3 flex flex-col min-h-75"
              :class="{
                'opacity-50': day.isPast,
                'bg-gray-800': !day.isToday,
                'border-2 border-blue-400 today-highlight': day.isToday
              }"
            >
              <!-- Date Number -->
              <div class="text-right mb-2 flex items-center justify-end">
                <div
                  v-if="day.isToday"
                  class="text-xs font-bold text-blue-200 bg-blue-600 px-2 py-1 rounded-full mr-2"
                >
                  TODAY
                </div>
                <div
                  class="font-bold text-xl"
                  :class="{
                    'text-blue-200 bg-blue-600 rounded-full w-8 h-8 flex items-center justify-center':
                      day.isToday,
                    'text-gray-300': day.isPast && !day.isToday,
                    'text-gray-500': !day.isToday && !day.isPast,
                  }"
                >
                  {{ day.dayNumber }}
                </div>
              </div>

              <!-- All-day Events for this day -->
              <div v-if="day.allDayEvents.length" class="mb-2">
                <div
                  v-for="event in day.allDayEvents"
                  :key="event.id"
                  class="text-xs px-2 py-1 rounded font-semibold mb-1 truncate shadow"
                  :style="{ backgroundColor: event.color }"
                  :title="event.title + ' (' + event.calendar + ') [All Day]'"
                >
                  {{ event.title }}  [All Day]
                </div>
              </div>

              <!-- Events for this day -->
              <div
                class="flex-1 space-y-1 overflow-y-auto day-events-container"
              >
                <div
                  v-for="event in day.events.slice(0, 10)"
                  :key="event.id"
                  class="text-xs p-1 rounded text-white flex items-start"
                  :style="{ backgroundColor: event.color }"
                  :title="
                    event.title +
                    ' - ' +
                    formatTime(event.start) +
                    ' (' +
                    event.calendar +
                    ')'
                  "
                >
                  <span class="line-clamp-2 leading-tight">
                    <span class="font-medium">{{
                      formatTime(event.start)
                    }}</span>
                    {{ event.title }}
                  </span>
                </div>
                <div
                  v-if="day.events.length > 10"
                  class="text-xs text-gray-400 text-center"
                >
                  +{{ day.events.length - 10 }} more
                </div>
              </div>
            </div>
          </div>

          <!-- Inspirational Quotes Section -->
          <div
            class="mt-8 flex flex-col items-center justify-center min-h-[80px]"
          >
            <div v-if="quotesLoading" class="text-gray-400 text-center">
              Loading quotes...
            </div>
            <div v-else-if="quotesError" class="text-red-400 text-center">
              Failed to load quotes
            </div>
            <div
              v-else
              class="text-2xl italic text-gray-200 text-center transition-opacity duration-500"
              :key="currentQuoteIndex"
            >
              {{ quotes[currentQuoteIndex] }}
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted } from "vue";

// Quotes state
const quotes = ref([]);
const currentQuoteIndex = ref(0);
const quotesLoading = ref(true);
const quotesError = ref(null);

const fetchQuotes = async () => {
  try {
    quotesLoading.value = true;
    const response = await fetch(
      "https://kevin-larry-bauer.github.io/quote-archive/quotes.json"
    );
    const data = await response.json();
    // Support both array and {quotes: array} formats
    const arr = Array.isArray(data) ? data : data.quotes;
    quotes.value = arr.map((q) => `"${q.text}" – ${q.author}`);
    currentQuoteIndex.value = Math.floor(Math.random() * quotes.value.length);
    quotesError.value = null;
  } catch (e) {
    quotesError.value = e;
  } finally {
    quotesLoading.value = false;
  }
};

// Fetch events from our API (non-blocking)
const data = ref(null);
const pending = ref(true);
const error = ref(null);

const fetchEvents = async () => {
  try {
    pending.value = true;
    const response = await $fetch("/api/events");
    data.value = response;
    error.value = null;
  } catch (e) {
    error.value = e;
  } finally {
    pending.value = false;
  }
};

// Current time and date
const currentTime = ref("");
const currentDate = ref("");

// Update time every second
let timeInterval;
let refreshInterval;
let dailyReloadInterval;

onMounted(() => {
  updateTime();
  fetchEvents();
  fetchQuotes();
  timeInterval = setInterval(updateTime, 1000);

  // Refresh calendar events every 15 minutes (900,000 ms)
  refreshInterval = setInterval(() => {
    console.log("Refreshing calendar events...");
    fetchEvents();
  }, 15 * 60 * 1000);

  // Reload the entire page once a day (24 hours = 86,400,000 ms)
  dailyReloadInterval = setInterval(() => {
    console.log("Daily page reload...");
    window.location.reload();
  }, 24 * 60 * 60 * 1000);
});

onUnmounted(() => {
  if (timeInterval) clearInterval(timeInterval);
  if (refreshInterval) clearInterval(refreshInterval);
  if (dailyReloadInterval) clearInterval(dailyReloadInterval);
});

const updateTime = () => {
  const now = new Date();
  currentTime.value = now.toLocaleTimeString("en-US", {
    hour: "numeric",
    minute: "2-digit",
    hour12: true,
  });
  currentDate.value = now.toLocaleDateString("en-US", {
    weekday: "long",
    month: "long",
    day: "numeric",
  });
};

// Day headers for the calendar
const dayHeaders = [
  "Sunday",
  "Monday",
  "Tuesday",
  "Wednesday",
  "Thursday",
  "Friday",
  "Saturday",
];

// Get today's events
const todayEvents = computed(() => {
  if (!data.value?.events) return [];

  const today = new Date();
  const todayStr = today.toDateString();

  return data.value.events
    .filter((event) => new Date(event.start).toDateString() === todayStr)
    .sort((a, b) => new Date(a.start) - new Date(b.start));
});

// Helper: check if event is all-day
const isAllDayEvent = (event) => {
  // If start and end are both at midnight and duration is >= 24h, or if end minus start is a whole number of days
  const start = new Date(event.start);
  const end = new Date(event.end);
  const isMidnight = (d) =>
    d.getHours() === 0 && d.getMinutes() === 0 && d.getSeconds() === 0;
  const msInDay = 24 * 60 * 60 * 1000;
  const duration = end - start;
  // Allow for floating point error
  return (
    isMidnight(start) &&
    isMidnight(end) &&
    duration % msInDay === 0 &&
    duration >= msInDay
  );
};

// Generate calendar days for current week and next week
const calendarDays = computed(() => {
  if (!data.value?.events) return [];

  const today = new Date();
  today.setHours(0, 0, 0, 0); // Normalize to midnight
  const startOfWeek = new Date(today);
  startOfWeek.setDate(today.getDate() - today.getDay()); // Start from Sunday
  startOfWeek.setHours(0, 0, 0, 0);

  const days = [];
  // Generate 14 days (2 weeks)
  for (let i = 0; i < 14; i++) {
    const date = new Date(startOfWeek);
    date.setDate(startOfWeek.getDate() + i);
    date.setHours(0, 0, 0, 0);
    // All-day events: include if this day is between start (inclusive) and end (exclusive)
    const allDayEvents = data.value.events
      .filter((event) => {
        if (!isAllDayEvent(event)) return false;
        const eventStart = new Date(event.start);
        const eventEnd = new Date(event.end);
        eventStart.setHours(0, 0, 0, 0);
        eventEnd.setHours(0, 0, 0, 0);
        // All-day events are inclusive of start, exclusive of end
        return date >= eventStart && date < eventEnd;
      })
      .sort((a, b) => a.title.localeCompare(b.title));
    // Timed events: only those that start on this day
    const timedEvents = data.value.events
      .filter((event) => {
        if (isAllDayEvent(event)) return false;
        const eventDate = new Date(event.start);
        return eventDate.toDateString() === date.toDateString();
      })
      .sort((a, b) => new Date(a.start) - new Date(b.start));
    days.push({
      date: date.toISOString(),
      dayNumber: date.getDate(),
      isToday: date.toDateString() === today.toDateString(),
      isCurrentMonth: date.getMonth() === today.getMonth(),
      isPast: date < today,
      allDayEvents,
      events: timedEvents,
    });
  }
  return days;
});

// Week range text
const weekRangeText = computed(() => {
  if (calendarDays.value.length === 0) return "";

  const firstDay = new Date(calendarDays.value[0].date);
  const lastDay = new Date(calendarDays.value[13].date);

  const formatOptions = { month: "long", day: "numeric" };
  const firstStr = firstDay.toLocaleDateString("en-US", formatOptions);
  const lastStr = lastDay.toLocaleDateString("en-US", formatOptions);

  return `${firstStr} - ${lastStr}, ${lastDay.getFullYear()}`;
});

// Inspirational Quotes
let quoteInterval;
let quoteReloadInterval;

onMounted(() => {
  quoteInterval = setInterval(() => {
    if (!quotes.value.length) return;
    let nextIndex;
    do {
      nextIndex = Math.floor(Math.random() * quotes.value.length);
    } while (nextIndex === currentQuoteIndex.value);
    currentQuoteIndex.value = nextIndex;
  }, 20000);

  // Reload quotes every 20 minutes
  quoteReloadInterval = setInterval(() => {
    fetchQuotes();
  }, 20 * 60 * 1000);
});

onUnmounted(() => {
  if (quoteInterval) clearInterval(quoteInterval);
  if (quoteReloadInterval) clearInterval(quoteReloadInterval);
});

// Helper to get event duration in minutes
const getEventDurationMinutes = (event) => {
  const start = new Date(event.start);
  const end = new Date(event.end);
  return Math.round((end.getTime() - start.getTime()) / 60000);
};

// Utility functions
const formatTime = (dateString) => {
  const date = new Date(dateString);
  return date.toLocaleTimeString("en-US", {
    hour: "numeric",
    minute: "2-digit",
    hour12: true,
  });
};

const formatLastUpdated = (dateString) => {
  const date = new Date(dateString);
  return date.toLocaleTimeString("en-US", {
    hour: "numeric",
    minute: "2-digit",
    hour12: true,
  });
};

// Helper to format hour labels (7am to 10pm)
const formatHour = (h) => {
  const hour = h % 24;
  const ampm =
    hour === 0
      ? "12 AM"
      : hour < 12
      ? `${hour} AM`
      : hour === 12
      ? "12 PM"
      : `${hour - 12} PM`;
  return ampm;
};
// Helper to position events in the day view (7am to 10pm)
const getEventStyleDayView = (event) => {
  const start = new Date(event.start);
  const end = new Date(event.end);
  // Only show events between 7am (420) and 10pm (1320)
  const gridStart = 7 * 60;
  const gridEnd = 22 * 60;
  let startMinutes = start.getHours() * 60 + start.getMinutes();
  let endMinutes = end.getHours() * 60 + end.getMinutes();
  // Clamp to grid
  if (startMinutes < gridStart) startMinutes = gridStart;
  if (endMinutes > gridEnd) endMinutes = gridEnd;
  if (endMinutes < startMinutes) endMinutes = startMinutes + 30; // minimum 30 min event
  const top = startMinutes - gridStart; // in minutes
  let height = endMinutes - startMinutes;
  if (height < 30) height = 30; // minimum height for visibility
  return {
    top: `${top + 1}px`,
    height: `${height - 2}px`,
  };
};

// Set page meta
useHead({
  title: "Family Calendar Dashboard",
  meta: [
    { name: "description", content: "Fullscreen family calendar dashboard" },
  ],
});
</script>

<style scoped>
/* Hide scrollbar for day event containers */
.day-events-container {
  scrollbar-width: none; /* Firefox */
  -ms-overflow-style: none; /* Internet Explorer 10+ */
}

.day-events-container::-webkit-scrollbar {
  display: none; /* Safari and Chrome */
}

/* Line clamp utility for text truncation */
.line-clamp-2 {
  display: -webkit-box;
  -webkit-line-clamp: 2;
  line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
  word-break: break-word;
}

/* Enhanced today highlight with animation */
.today-highlight {
  animation: pulse-glow 2s ease-in-out infinite alternate;
  background: linear-gradient(135deg, #1e3a8a 0%, #1e40af 50%, #1d4ed8 100%);
  position: relative;
}

.today-highlight::before {
  content: "";
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: radial-gradient(
    circle at 20% 20%,
    rgba(59, 130, 246, 0.1) 0%,
    transparent 50%
  );
  border-radius: inherit;
  pointer-events: none;
}

@keyframes pulse-glow {
  from {
    box-shadow: 0 0 10px rgba(59, 130, 246, 0.3),
      0 0 20px rgba(59, 130, 246, 0.1);
  }
  to {
    box-shadow: 0 0 20px rgba(59, 130, 246, 0.5),
      0 0 30px rgba(59, 130, 246, 0.2);
  }
}
</style>
