#!/bin/bash
# Launch Chrome in kiosk mode
cd ~/family-calendar

git pull

npm run build

npm run start &

# Launch Chromium in kiosk mode
google-chrome \
  --kiosk \
  --noerrdialogs \
  --disable-infobars \
  --disable-restore-session-state \
  --disable-features=TranslateUI \
  --disable-pinch \
  --overscroll-history-navigation=0 \
  --disable-gesture-typing \
  --disable-touch-drag-drop \
  --disable-touch-editing \
  --disable-touch-selection \
  --disable-touch-feedback \
  --disable-touch-events \
  --disable-virtual-keyboard \
  --disable-automatic-password-saving \
  --disable-save-password-bubble \
  --disable-password-manager-reauthentication \
  --disable-password-manager \
  --app="http://localhost:3000"
      