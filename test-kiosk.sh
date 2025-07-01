#!/bin/bash

# Test script to verify the kiosk setup is working correctly
# Run this on your Raspberry Pi after installation

echo "🧪 Family Calendar Kiosk Test"
echo "=============================="

# Test 1: Check if required commands exist
echo "📋 Checking required commands..."
commands=("node" "npm" "git" "chromium-browser" "pm2")
for cmd in "${commands[@]}"; do
    if command -v "$cmd" >/dev/null 2>&1; then
        echo "✅ $cmd is installed"
    else
        echo "❌ $cmd is missing"
    fi
done

# Test 2: Check if repository exists
REPO_DIR="/home/pi/family-calendar"
if [ -d "$REPO_DIR" ]; then
    echo "✅ Repository directory exists: $REPO_DIR"
    cd "$REPO_DIR"
    
    # Check if it's a valid git repo
    if git status >/dev/null 2>&1; then
        echo "✅ Valid git repository"
        echo "📍 Current branch: $(git branch --show-current)"
        echo "📍 Last commit: $(git log -1 --oneline)"
    else
        echo "❌ Not a valid git repository"
    fi
else
    echo "❌ Repository directory not found: $REPO_DIR"
fi

# Test 3: Check if calendar config exists
CONFIG_FILE="$REPO_DIR/calendar-locations.json"
if [ -f "$CONFIG_FILE" ]; then
    echo "✅ Calendar configuration exists"
    echo "📍 Number of calendars: $(jq '.calendars | length' "$CONFIG_FILE" 2>/dev/null || echo "Invalid JSON")"
else
    echo "❌ Calendar configuration missing: $CONFIG_FILE"
fi

# Test 4: Check systemd service
echo "📋 Checking systemd service..."
if systemctl is-enabled family-calendar-kiosk >/dev/null 2>&1; then
    echo "✅ Service is enabled"
    SERVICE_STATUS=$(systemctl is-active family-calendar-kiosk)
    echo "📍 Service status: $SERVICE_STATUS"
else
    echo "❌ Service is not enabled"
fi

# Test 5: Check if application is running
echo "📋 Checking application status..."
if pm2 list | grep -q "family-calendar"; then
    echo "✅ Application is running in PM2"
    pm2 list | grep family-calendar
else
    echo "❌ Application not found in PM2"
fi

# Test 6: Check if port is accessible
echo "📋 Checking application accessibility..."
if curl -s "http://localhost:3000" >/dev/null; then
    echo "✅ Application is responding on port 3000"
else
    echo "❌ Application is not responding on port 3000"
fi

# Test 7: Check display environment
echo "📋 Checking display environment..."
if [ -n "$DISPLAY" ]; then
    echo "✅ DISPLAY is set: $DISPLAY"
else
    echo "⚠️  DISPLAY not set (normal for SSH sessions)"
fi

# Test 8: Check browser process
if pgrep chromium-browser >/dev/null; then
    echo "✅ Chromium browser is running"
else
    echo "❌ Chromium browser is not running"
fi

echo ""
echo "🏁 Test completed!"
echo ""
echo "💡 If you see any ❌ errors:"
echo "   1. Run the installer again: ./install-kiosk.sh"
echo "   2. Check logs: ./startup-kiosk.sh logs"
echo "   3. Try manual start: ./startup-kiosk.sh"
