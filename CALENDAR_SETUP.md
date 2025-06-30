# Calendar Configuration Example

To configure your Google Calendar feeds, create a `calendar-locations.json` file in the root directory with the following structure:

```json
{
  "calendars": [
    {
      "name": "Family Calendar",
      "url": "https://calendar.google.com/calendar/ical/your-calendar-id@group.calendar.google.com/public/basic.ics",
      "color": "#4285f4"
    },
    {
      "name": "Work Calendar", 
      "url": "https://calendar.google.com/calendar/ical/another-calendar-id@gmail.com/public/basic.ics",
      "color": "#34a853"
    }
  ]
}
```

## How to get Google Calendar ICS URLs:

1. Open Google Calendar in your web browser
2. Click on the three dots next to the calendar you want to share
3. Select "Settings and sharing"
4. Scroll down to "Access permissions for events"
5. Check "Make available to public" (if you want it public)
6. Scroll down to "Integrate calendar"
7. Copy the "Public URL to this calendar" (the .ics link)

## Color Options:

You can use any valid CSS color for the `color` field:
- Hex colors: `#4285f4`, `#ff5722`
- Color names: `red`, `blue`, `green`
- RGB: `rgb(66, 133, 244)`

The color will be used to identify events from different calendars in the UI.
