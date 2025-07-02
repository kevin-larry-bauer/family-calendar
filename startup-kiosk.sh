#!/bin/bash

# Family Calendar Kiosk Startup Script
# Place this script on your Raspberry Pi and configure it to run on startup

# Configuration - Update these paths for your Raspberry Pi
REPO_DIR="/home/pi/family-calendar"  # Change this to your actual repo path
REPO_URL="https://github.com/kevin-larry-bauer/family-calendar.git"  # Change to your repo URL
LOG_FILE="/home/pi/family-calendar-startup.log"
PORT=3000

# Function to log messages with timestamp
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to wait for network connectivity
wait_for_network() {
    log_message "Waiting for network connectivity..."
    while ! ping -c 1 google.com &> /dev/null; do
        log_message "Network not available, waiting 5 seconds..."
        sleep 5
    done
    log_message "Network connectivity confirmed"
}

# Function to install dependencies if needed
install_dependencies() {
    log_message "Checking and installing dependencies..."
    
    # Update package list
    sudo apt update
    
    # Install Node.js if not present
    if ! command_exists node; then
        log_message "Installing Node.js..."
        curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
        sudo apt-get install -y nodejs
    fi
    
    # Install Git if not present
    if ! command_exists git; then
        log_message "Installing Git..."
        sudo apt-get install -y git
    fi
    
    # Install Chromium browser if not present
    if ! command_exists chromium-browser; then
        log_message "Installing Chromium browser..."
        sudo apt-get install -y chromium-browser
    fi
    
    # Install pm2 for process management
    if ! command_exists pm2; then
        log_message "Installing PM2..."
        sudo npm install -g pm2
    fi
}

# Function to setup or update the repository
setup_repository() {
    log_message "Setting up repository..."
    
    if [ -d "$REPO_DIR" ]; then
        log_message "Repository exists, pulling latest changes..."
        cd "$REPO_DIR"
        
        # Stash any local changes
        git stash
        
        # Pull latest changes
        if git pull origin main; then
            log_message "Successfully pulled latest changes"
        else
            log_message "Failed to pull changes, trying to reset..."
            git reset --hard origin/main
        fi
    else
        log_message "Cloning repository..."
        mkdir -p "$(dirname "$REPO_DIR")"
        if git clone "$REPO_URL" "$REPO_DIR"; then
            log_message "Repository cloned successfully"
            cd "$REPO_DIR"
        else
            log_message "Failed to clone repository"
            exit 1
        fi
    fi
}

# Function to setup calendar configuration
setup_calendar_config() {
    log_message "Checking calendar configuration..."
    
    if [ ! -f "$REPO_DIR/calendar-locations.json" ]; then
        log_message "Creating sample calendar configuration..."
        cat > "$REPO_DIR/calendar-locations.json" << EOF
{
  "calendars": [
    {
      "name": "Sample Calendar",
      "url": "https://calendar.google.com/calendar/ical/en.usa%23holiday%40group.v.calendar.google.com/public/basic.ics",
      "color": "#4285f4"
    }
  ]
}
EOF
        log_message "Sample configuration created. Please update calendar-locations.json with your actual calendar URLs."
    fi
}

# Function to build and start the application
build_app() {
    log_message "Building and starting the application..."
    
    cd "$REPO_DIR"
    
    # Install npm dependencies
    log_message "Installing npm dependencies..."
    if npm install; then
        log_message "Dependencies installed successfully"
    else
        log_message "Failed to install dependencies"
        exit 1
    fi
    
    # Build for production
    log_message "Building for production..."
    if npm run build; then
        log_message "Build completed successfully"
    else
        log_message "Build failed"
        exit 1
    fi
}

start_app() {
    # Stop any existing PM2 processes
    pm2 delete family-calendar 2>/dev/null || true
    
    # Start the application with PM2
    log_message "Starting application with PM2..."
    if [ -f ".output/server/index.mjs" ]; then
        # Use the proper start script for production
        if pm2 start npm --name "family-calendar" -- start; then
            log_message "Application started successfully using npm start"
            pm2 save
        else
            log_message "Failed to start with npm start, trying direct node execution..."
            if pm2 start .output/server/index.mjs --name "family-calendar"; then
                log_message "Application started successfully using direct execution"
                pm2 save
            else
                log_message "Failed to start application"
                exit 1
            fi
        fi
    else
        log_message "Built output not found (.output/server/index.mjs), build may have failed"
        log_message "Checking build output..."
        ls -la .output/ 2>/dev/null || log_message "No .output directory found"
        log_message "Trying npm preview as fallback..."
        if pm2 start npm --name "family-calendar" -- run preview; then
            log_message "Application started successfully using npm preview"
            pm2 save
        else
            log_message "Failed to start application with preview mode"
            exit 1
        fi
    fi
    
    # Wait for the application to be ready
    log_message "Waiting for application to be ready..."
    APPLICATION_READY=false
    for i in {1..30}; do
        if curl -s "http://localhost:$PORT" > /dev/null; then
            log_message "Application is ready and responding"
            APPLICATION_READY=true
            break
        fi
        log_message "Waiting for application... ($i/30)"
        sleep 2
    done
    
    if [ "$APPLICATION_READY" = false ]; then
        log_message "Application failed to start properly. Checking PM2 status..."
        pm2 status
        pm2 logs family-calendar --lines 20
        log_message "Attempting to restart application..."
        pm2 restart family-calendar
        sleep 5
        if curl -s "http://localhost:$PORT" > /dev/null; then
            log_message "Application started after restart"
        else
            log_message "Application still not responding. Check logs manually."
        fi
    fi
}

# Function to start browser in kiosk mode
start_kiosk_browser() {
    log_message "Starting browser in kiosk mode..."
    
    # Set display environment
    export DISPLAY=:0
    
    # Wait a bit for the desktop to be ready
    sleep 5
    
    # Kill any existing chromium processes
    pkill chromium-browser 2>/dev/null || true
    sleep 2
    
    # Start Chromium in kiosk mode
    log_message "Launching Chromium browser..."
    chromium-browser \
        --kiosk \
        --noerrdialogs \
        --disable-infobars \
        --disable-session-crashed-bubble \
        --disable-dev-shm-usage \
        --no-sandbox \
        --disable-features=TranslateUI \
        --disable-ipc-flooding-protection \
        --autoplay-policy=no-user-gesture-required \
        --app="http://localhost:$PORT" \
        > /dev/null 2>&1 &
    
    log_message "Browser started in kiosk mode"
}

# Function to setup auto-refresh
setup_auto_refresh() {
    log_message "Setting up auto-refresh..."
    
    # Create a script that will refresh the page every hour
    cat > "/home/pi/refresh-calendar.sh" << 'EOF'
#!/bin/bash
export DISPLAY=:0
xdotool search --name "Chromium" key F5 2>/dev/null || {
    # If browser is not found, restart it
    /home/pi/startup-kiosk.sh restart_browser
}
EOF
    
    chmod +x "/home/pi/refresh-calendar.sh"
    
    # Add cron job for hourly refresh (if not already exists)
    if ! crontab -l 2>/dev/null | grep -q "refresh-calendar.sh"; then
        (crontab -l 2>/dev/null; echo "0 * * * * /home/pi/refresh-calendar.sh") | crontab -
        log_message "Auto-refresh cron job added"
    fi
}

# Main execution
main() {
    log_message "=== Family Calendar Kiosk Startup ==="
    log_message "Starting kiosk setup process..."
    
    # Wait for network
    wait_for_network
    
    # Install dependencies
    # install_dependencies
    
    # Setup repository
    # setup_repository
    
    # Setup calendar configuration
    # setup_calendar_config
    
    # Build and start application
    # build_app
    start_app

    # Setup auto-refresh
    setup_auto_refresh
    
    # Start kiosk browser
    start_kiosk_browser
    
    log_message "=== Kiosk setup completed ==="
}

# Handle command line arguments
case "$1" in
    "restart_browser")
        log_message "Restarting browser..."
        pkill chromium-browser 2>/dev/null || true
        sleep 2
        start_kiosk_browser
        ;;
    "update")
        log_message "Updating application..."
        setup_repository
        build_app
        start_app
        ;;
    "logs")
        tail -f "$LOG_FILE"
        ;;
    "debug")
        log_message "=== Debug Information ==="
        log_message "PM2 Status:"
        pm2 status
        log_message "PM2 Logs (last 20 lines):"
        pm2 logs family-calendar --lines 20
        log_message "Application status:"
        curl -I "http://localhost:$PORT" 2>/dev/null || log_message "Application not responding"
        log_message "Process information:"
        ps aux | grep -E "(node|npm|family-calendar)" | grep -v grep
        ;;
    *)
        main
        ;;
esac
