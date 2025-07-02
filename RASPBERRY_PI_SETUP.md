# Raspberry Pi Kiosk Setup for Family Calendar

This guide will help you set up your Raspberry Pi as a dedicated family calendar display that automatically updates and shows your calendar in kiosk mode.

## Prerequisites

- Raspberry Pi with Raspberry Pi OS installed
- Network connectivity (WiFi or Ethernet)
- Your family calendar repository URL
- Calendar configuration file (`calendar-locations.json`)

## Quick Setup

**Option 1: One-line install (with your repo URL)**
```bash
curl -s https://raw.githubusercontent.com/your-username/family-calendar/main/install-kiosk.sh | bash -s -- https://github.com/your-username/family-calendar.git
```

**Option 2: One-line install with custom directory**
```bash
curl -s https://raw.githubusercontent.com/your-username/family-calendar/main/install-kiosk.sh | bash -s -- https://github.com/your-username/family-calendar.git /home/pi/apps
```

**Option 3: Download and run interactively**
```bash
cd /home/pi
wget https://raw.githubusercontent.com/your-username/family-calendar/main/install-kiosk.sh
chmod +x install-kiosk.sh
./install-kiosk.sh
```
*(This will prompt for both repository URL and installation directory)*

**Option 3: Manual setup**

1. **Download the scripts to your Raspberry Pi:**
   ```bash
   cd /home/pi
   wget https://raw.githubusercontent.com/your-username/family-calendar/main/startup-kiosk.sh
   wget https://raw.githubusercontent.com/your-username/family-calendar/main/family-calendar-kiosk.service
   chmod +x startup-kiosk.sh
   ```

2. **Edit the configuration in `startup-kiosk.sh`:**
   ```bash
   nano startup-kiosk.sh
   ```
   
   Update these variables:
   - `REPO_URL`: Your GitHub repository URL
   - `REPO_DIR`: Directory where you want the code (default: `/home/pi/family-calendar`)

3. **Install and enable the systemd service:**
   ```bash
   sudo cp family-calendar-kiosk.service /etc/systemd/system/
   sudo systemctl daemon-reload
   sudo systemctl enable family-calendar-kiosk.service
   ```

4. **Test the setup:**
   ```bash
   ./startup-kiosk.sh
   ```

5. **Reboot to test automatic startup:**
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
Create `/home/pi/family-calendar/calendar-locations.json`:
```json
{
  "calendars": [
    {
      "name": "Family",
      "url": "https://calendar.google.com/calendar/ical/your-calendar-id/basic.ics",
      "color": "#4285f4"
    }
  ]
}
```

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
