#!/bin/bash

# Quick installer for Raspberry Pi Family Calendar Kiosk
# Run this script on your Raspberry Pi to set everything up automatically

set -e

echo "🏠 Family Calendar Kiosk Installer"
echo "=================================="

# Check if repository URL was provided as argument
if [ -n "$1" ]; then
    REPO_URL="$1"
    echo "📍 Using repository URL: $REPO_URL"
    
    # Check for optional second parameter (install directory)
    if [ -n "$2" ]; then
        INSTALL_DIR="$2"
        echo "📍 Using custom installation directory: $INSTALL_DIR"
    else
        INSTALL_DIR="/home/pi"
        echo "📍 Using default installation directory: $INSTALL_DIR"
    fi
else
    # Try to read from terminal (works when script is run directly)
    if [ -t 0 ]; then
        read -p "Enter your repository URL (e.g., https://github.com/username/family-calendar.git): " REPO_URL
        read -p "Enter installation directory [/home/pi]: " CUSTOM_INSTALL_DIR
        if [ -n "$CUSTOM_INSTALL_DIR" ]; then
            INSTALL_DIR="$CUSTOM_INSTALL_DIR"
        else
            INSTALL_DIR="/home/pi"
        fi
        echo "📍 Using installation directory: $INSTALL_DIR"
    else
        echo "❌ Repository URL is required when running via pipe"
        echo "💡 Usage: $0 <repository-url> [install-directory]"
        echo "💡 Example: $0 https://github.com/username/family-calendar.git"
        echo "💡 Example with custom directory: $0 https://github.com/username/family-calendar.git /home/pi/apps"
        echo "💡 Or download and run directly:"
        echo "   wget https://raw.githubusercontent.com/username/family-calendar/main/install-kiosk.sh"
        echo "   chmod +x install-kiosk.sh"
        echo "   ./install-kiosk.sh"
        exit 1
    fi
fi

if [ -z "$REPO_URL" ]; then
    echo "❌ Repository URL is required"
    exit 1
fi

REPO_DIR="$INSTALL_DIR/family-calendar"

echo "📁 Using installation directory: $INSTALL_DIR"
echo "📂 Repository will be cloned to: $REPO_DIR"

# Create installation directory if it doesn't exist
if [ ! -d "$INSTALL_DIR" ]; then
    echo "📁 Creating installation directory: $INSTALL_DIR"
    mkdir -p "$INSTALL_DIR"
fi

# Download the main startup script
echo "⬇️  Downloading startup script..."
cd "$INSTALL_DIR"
curl -s -o startup-kiosk.sh "https://raw.githubusercontent.com/your-username/family-calendar/main/startup-kiosk.sh"
chmod +x startup-kiosk.sh

# Update the repository URL in the script
echo "🔧 Configuring startup script..."
sed -i "s|REPO_URL=\".*\"|REPO_URL=\"$REPO_URL\"|g" startup-kiosk.sh
sed -i "s|REPO_DIR=\".*\"|REPO_DIR=\"$REPO_DIR\"|g" startup-kiosk.sh

# Download the systemd service file
echo "⬇️  Downloading service file..."
curl -s -o family-calendar-kiosk.service "https://raw.githubusercontent.com/your-username/family-calendar/main/family-calendar-kiosk.service"

# Install the systemd service
echo "🔧 Installing systemd service..."
sudo cp family-calendar-kiosk.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable family-calendar-kiosk.service

echo "✅ Installation complete!"
echo ""
echo "📋 Next steps:"
echo "1. Edit your calendar configuration:"
echo "   nano $REPO_DIR/calendar-locations.json"
echo ""
echo "2. Test the setup:"
echo "   ./startup-kiosk.sh"
echo ""
echo "3. Reboot to test automatic startup:"
echo "   sudo reboot"
echo ""
echo "📖 For detailed instructions, see: $REPO_DIR/RASPBERRY_PI_SETUP.md"
echo ""
echo "🔍 Useful commands:"
echo "   ./startup-kiosk.sh logs     # View logs"
echo "   ./startup-kiosk.sh update   # Update app"
echo "   ./test-kiosk.sh             # Test installation"
echo "   sudo systemctl status family-calendar-kiosk  # Check service"
