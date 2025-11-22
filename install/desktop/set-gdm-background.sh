#!/bin/bash

# Set GDM (login screen) background to match user wallpaper
# This script sets the login screen background to match the Bentobox wallpaper

echo "Setting GDM login screen background..."

# The wallpaper we want to use
WALLPAPER_SOURCE="$HOME/.local/share/backgrounds/omakub/pexels-pok-rie-33563-2049422.jpg"

# Check if wallpaper exists
if [ ! -f "$WALLPAPER_SOURCE" ]; then
    echo "⚠️  Wallpaper not found at $WALLPAPER_SOURCE"
    echo "Skipping GDM background setup..."
    exit 0
fi

# Copy wallpaper to system location
sudo mkdir -p /usr/share/backgrounds/bentobox
sudo cp "$WALLPAPER_SOURCE" /usr/share/backgrounds/bentobox/login-background.jpg
sudo chmod 644 /usr/share/backgrounds/bentobox/login-background.jpg

# Create GDM background CSS override
sudo mkdir -p /etc/dconf/db/gdm.d

# Set the background for GDM
sudo tee /etc/dconf/db/gdm.d/01-bentobox-background > /dev/null << 'EOF'
[org/gnome/desktop/background]
picture-uri='file:///usr/share/backgrounds/bentobox/login-background.jpg'
picture-uri-dark='file:///usr/share/backgrounds/bentobox/login-background.jpg'
picture-options='zoom'

[org/gnome/desktop/screensaver]
picture-uri='file:///usr/share/backgrounds/bentobox/login-background.jpg'
picture-options='zoom'
EOF

# Update dconf database
sudo dconf update

# Also set it via GDM CSS (alternative method for older systems)
GDMCSS="/usr/share/gnome-shell/theme/ubuntu.css"

if [ -f "$GDMCSS" ]; then
    # Backup original CSS if not already backed up
    if [ ! -f "$GDMCSS.bak" ]; then
        sudo cp "$GDMCSS" "$GDMCSS.bak"
    fi
    
    # Add background image to GDM CSS
    if ! grep -q "bentobox/login-background.jpg" "$GDMCSS"; then
        sudo sed -i '/lockDialogGroup {/a \  background-image: url("file:///usr/share/backgrounds/bentobox/login-background.jpg");\n  background-size: cover;\n  background-position: center;' "$GDMCSS"
    fi
fi

echo "✅ GDM login screen background set!"
echo "   Background: /usr/share/backgrounds/bentobox/login-background.jpg"
echo ""
echo "Note: You may need to reboot to see the changes on the login screen."

