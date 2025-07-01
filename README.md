# Family Calendar

A Nuxt.js application that displays events from multiple Google Calendar feeds in a beautiful, unified interface.

## Features

- 📅 Display events from multiple Google Calendar feeds
- 🎨 Color-coded events by calendar source
- 📱 Responsive design that works on all devices
- ⚡ Real-time calendar feed parsing
- 🔧 Easy configuration via JSON file
- 🖥️ **Raspberry Pi kiosk mode support** - Perfect for dedicated displays!

## 🍓 Raspberry Pi Kiosk Setup

Transform your Raspberry Pi into a dedicated family calendar display! The included scripts will:

- ✅ Automatically pull the latest code on startup
- ✅ Build for production
- ✅ Launch in full-screen kiosk mode
- ✅ Auto-refresh hourly
- ✅ Restart automatically if it crashes

### Quick Install on Raspberry Pi:

**Option 1: With repository URL as argument**
```bash
curl -s https://raw.githubusercontent.com/kevin-larry-bauer/family-calendar/main/install-kiosk.sh | bash -s -- https://github.com/your-username/family-calendar.git
```

**Option 2: With custom installation directory**
```bash
curl -s https://raw.githubusercontent.com/kevin-larry-bauer/family-calendar/main/install-kiosk.sh | bash -s -- https://github.com/your-username/family-calendar.git /home/pi/apps
```

**Option 3: Download and run interactively**
```bash
wget https://raw.githubusercontent.com/kevin-larry-bauer/family-calendar/main/install-kiosk.sh
chmod +x install-kiosk.sh
./install-kiosk.sh
```

See [RASPBERRY_PI_SETUP.md](RASPBERRY_PI_SETUP.md) for detailed instructions.

## Setup

Make sure to install dependencies:

```bash
# npm
npm install

# pnpm
pnpm install

# yarn
yarn install

# bun
bun install
```

## Calendar Configuration

1. Create a `calendar-locations.json` file in the root directory
2. Add your Google Calendar ICS URLs following this format:

```json
{
  "calendars": [
    {
      "name": "Family Calendar",
      "url": "https://calendar.google.com/calendar/ical/your-calendar-id@group.calendar.google.com/public/basic.ics",
      "color": "#4285f4"
    }
  ]
}
```

See `CALENDAR_SETUP.md` for detailed instructions on getting Google Calendar ICS URLs.

**Note:** The `calendar-locations.json` file is ignored by git for privacy. Each user needs to create their own configuration file.

## Development Server

Start the development server on `http://localhost:3000`:

```bash
# npm
npm run dev

# pnpm
pnpm dev

# yarn
yarn dev

# bun
bun run dev
```

## Production

Build the application for production:

```bash
# npm
npm run build

# pnpm
pnpm build

# yarn
yarn build

# bun
bun run build
```

Locally preview production build:

```bash
# npm
npm run preview

# pnpm
pnpm preview

# yarn
yarn preview

# bun
bun run preview
```

Check out the [deployment documentation](https://nuxt.com/docs/getting-started/deployment) for more information.
