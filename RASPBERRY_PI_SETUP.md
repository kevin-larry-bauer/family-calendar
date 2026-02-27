# Raspberry Pi Kiosk Setup for Family Calendar

This guide will help you set up your Raspberry Pi as a dedicated family calendar display that automatically updates and shows your calendar in kiosk mode.

## Prerequisites

- Raspberry Pi with Raspberry Pi OS installed
- Network connectivity (WiFi or Ethernet)
- Node.js installed

## Quick Setup

1. **Clone the repository and install:**
   ```bash
   cd /home/pi
   git clone https://github.com/your-username/family-calendar.git
   cd family-calendar
   npm install
   npm run build
   ```

2. **Install the startup script and service:**
   ```bash
   chmod +x startup-kiosk.sh
   sudo cp family-calendar-kiosk.service /etc/systemd/system/
   sudo systemctl daemon-reload
   sudo systemctl enable family-calendar-kiosk.service
   ```

3. **Start the app and configure calendars:**
   ```bash
   npm run start &
   ```
   Then open `http://localhost:3000/config` to add your calendar URLs and quote feed.

4. **Reboot to test kiosk mode:**
   ```bash
   sudo reboot
   ```

## What the Script Does

### 🔄 **Automatic Updates**
- Performs `git pull` on startup to get latest code
- Handles merge conflicts by stashing local changes
- Falls back to hard reset if needed

### 🏗️ **Production Build**
- Runs `npm install` to update dependencies
- Executes `npm run build` for optimized production build
- Uses PM2 for process management and auto-restart

### 🖥️ **Kiosk Mode**
- Launches Chromium browser in full-screen kiosk mode
- Disables browser UI elements and error dialogs
- Points to `http://localhost:3000`

### 🔄 **Auto-Refresh**
- Sets up hourly page refresh via cron job
- Restarts browser if it crashes
- Keeps calendar data current

## Manual Commands

### View logs:
```bash
./startup-kiosk.sh logs
```

### Debug application issues:
```bash
./startup-kiosk.sh debug
```

### Update application:
```bash
./startup-kiosk.sh update
```

### Restart browser only:
```bash
./startup-kiosk.sh restart_browser
```

### Check service status:
```bash
sudo systemctl status family-calendar-kiosk
```

### Check PM2 processes:
```bash
pm2 status
pm2 logs family-calendar
```

## Configuration Files

### Calendar Configuration

Calendar URLs and quotes are configured in the browser. After the app is running, open `http://localhost:3000/config` to add your Google Calendar ICS URLs.

For each calendar you add, provide:
- **Label** — a display name (e.g. "Family Calendar")
- **URL** — a Google Calendar ICS link
- **Color** — a hex color to identify this calendar's events

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

### Raspberry Pi Display Settings
For optimal display, consider adding to `/boot/config.txt`:
```
# Disable overscan for full screen
disable_overscan=1

# Set specific resolution if needed
hdmi_group=2
hdmi_mode=82  # 1080p 60Hz

# Rotate display if needed (0=normal, 1=90°, 2=180°, 3=270°)
display_rotate=0
```

## Troubleshooting

### Browser won't start:
```bash
# Check if X11 is running
echo $DISPLAY

# Restart X11 if needed
sudo service lightdm restart
```

### Application won't build:
```bash
# Check Node.js version
node --version

# Clear npm cache
cd /home/pi/family-calendar
npm cache clean --force
rm -rf node_modules package-lock.json
npm install
```

### Network issues:
```bash
# Test connectivity
ping google.com

# Restart networking
sudo service networking restart
```

### View detailed logs:
```bash
# Service logs
sudo journalctl -u family-calendar-kiosk -f

# Application logs
tail -f /home/pi/family-calendar-startup.log

# PM2 logs
pm2 logs family-calendar
```

## Performance Optimization

### For older Raspberry Pi models:
Add these settings to improve performance:

1. **Increase GPU memory split in `/boot/config.txt`:**
   ```
   gpu_mem=128
   ```

2. **Reduce browser resource usage in startup script:**
   Add these flags to chromium-browser command:
   ```
   --memory-pressure-off
   --max_old_space_size=512
   --disable-background-networking
   ```

3. **Enable hardware acceleration:**
   ```
   --enable-features=VaapiVideoDecoder
   --use-gl=egl
   ```

## Security Considerations

- The script runs with pi user privileges
- Repository should be public or use SSH keys for private repos
- Consider using a dedicated calendar service account
- Firewall the Pi to only allow necessary traffic

## Customization

### Auto-reboot daily:
Add to crontab:
```bash
crontab -e
# Add: 0 4 * * * sudo reboot
```

### Different refresh intervals:
Edit the cron job in the setup script to change frequency.

### Custom styling:
The calendar application will use your CSS from the repository automatically.
