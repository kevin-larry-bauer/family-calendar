# Family Calendar

A Nuxt.js application that displays events from multiple Google Calendar feeds in a beautiful, unified dashboard. Configuration is done entirely in the browser — no server-side config files needed.

## Features

- 📅 Display events from multiple Google Calendar feeds
- 🎨 Color-coded events by calendar source
- 📱 Responsive design that works on all devices
- ⚡ Client-side iCal parsing with automatic refresh
- 🔧 In-browser configuration page (`/config`) — no config files
- 💬 Inspirational quotes from a configurable JSON URL
- 🖥️ **Raspberry Pi kiosk mode support** - Perfect for dedicated displays!

## 🍓 Kiosk Setup

Transform any computer into a dedicated family calendar display! For a raspberry pi see [RASPBERRY_PI_SETUP.md](RASPBERRY_PI_SETUP.md) for detailed instructions.

The included `startup-kiosk.sh` script launches Chromium in full-screen kiosk mode pointed at the app.

Before running in kiosk mode, visit localhost:3000/config to set the URLs for Google Calendar and for your quote list (see instructions below)
## Setup

Install dependencies:

```bash
npm install
```

## Calendar Configuration

Calendar URLs and the quote file URL are configured directly in the browser via the built-in configuration page — no server-side config files needed.

1. Start the app and navigate to `/config`
2. Add your Google Calendar ICS URLs, each with a label and color
3. Optionally set a quotes JSON URL
4. Click **Save** — settings are stored in the browser's `localStorage`

The main dashboard (`/`) reads these settings on load and fetches calendar data client-side through a server proxy (to avoid CORS restrictions).

### localStorage format

The config is stored under the key `familyCalendarConfig`:

```json
{
  "calendars": [
    {
      "label": "Family Calendar",
      "url": "https://calendar.google.com/calendar/ical/your-calendar-id/public/basic.ics",
      "color": "#4285f4"
    }
  ],
  "quoteUrl": "https://example.com/quotes.json"
}
```

See `CALENDAR_SETUP.md` for detailed instructions on getting Google Calendar ICS URLs.

### Quote file format

The quote URL should return JSON — either a plain array or an object with a `quotes` key. Each entry needs `text` and `author` fields:

```json
{
  "quotes": [
    { "text": "The best time to plant a tree was 20 years ago. The second best time is now.", "author": "Chinese Proverb" },
    { "text": "Be yourself; everyone else is already taken.", "author": "Oscar Wilde" }
  ]
}
```

A plain array format also works:

```json
[
  { "text": "Stay hungry, stay foolish.", "author": "Steve Jobs" }
]
```

## Development Server

Start the development server on `http://localhost:3000`:

```bash
npm run dev
```

## Production

Build and run for production:

```bash
npm run build
npm run start
```

Check out the [deployment documentation](https://nuxt.com/docs/getting-started/deployment) for more information.
