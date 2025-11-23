#!/bin/bash

# Set GDM3 Login Greeter Background (not just lock screen)
# This modifies the actual GDM theme to show custom wallpaper
# Works with any user account that has sudo privileges

echo "Setting GDM3 login greeter background..."

WALLPAPER_SOURCE="$HOME/.local/share/backgrounds/omakub/pexels-pok-rie-33563-2049422.jpg"

# Check if wallpaper exists
if [ ! -f "$WALLPAPER_SOURCE" ]; then
    echo "❌ ERROR: Wallpaper not found!"
    echo "   Expected location: $WALLPAPER_SOURCE"
    echo "   This means set-wallpaper.sh failed to copy wallpapers."
    echo ""
    echo "   Checking wallpaper directory:"
    ls -la "$HOME/.local/share/backgrounds/omakub/" 2>/dev/null || echo "   Directory doesn't exist!"
    echo ""
    echo "⚠️  Skipping GDM background setup..."
    exit 0
fi

echo "✅ Wallpaper found: $WALLPAPER_SOURCE"

# Copy wallpaper to system location
echo "📋 Copying wallpaper to system directory..."
sudo mkdir -p /usr/share/backgrounds/bentobox
sudo cp "$WALLPAPER_SOURCE" /usr/share/backgrounds/bentobox/gdm-background.jpg
sudo chmod 644 /usr/share/backgrounds/bentobox/gdm-background.jpg

if [ -f /usr/share/backgrounds/bentobox/gdm-background.jpg ]; then
    echo "✅ Wallpaper copied to /usr/share/backgrounds/bentobox/gdm-background.jpg"
else
    echo "❌ ERROR: Failed to copy wallpaper to system directory!"
    exit 1
fi

# Method 1: Extract and modify GDM theme
GDM_THEME_DIR="/usr/share/gnome-shell/theme"
GDM_THEME_FILE="$GDM_THEME_DIR/ubuntu.css"

if [ -f "$GDM_THEME_FILE" ]; then
    echo "📝 Modifying GDM theme CSS..."
    # Backup original if not already backed up
    if [ ! -f "$GDM_THEME_FILE.bak" ]; then
        sudo cp "$GDM_THEME_FILE" "$GDM_THEME_FILE.bak"
        echo "   Backed up original theme"
    fi
    
    # Add/modify background in CSS
    sudo tee "$GDM_THEME_FILE" > /dev/null << 'EOF'
#lockDialogGroup {
  background: url(file:///usr/share/backgrounds/bentobox/gdm-background.jpg);
  background-size: cover;
  background-repeat: no-repeat;
  background-position: center;
}

.login-dialog {
  background: rgba(0, 0, 0, 0.3);
}

.login-dialog-banner {
  background: rgba(0, 0, 0, 0.5);
}
EOF
    echo "   ✅ Theme CSS updated"
fi

# Method 2: Use alternatives system
echo "📝 Setting up alternatives system..."
sudo update-alternatives --install /usr/share/backgrounds/gdm-background /usr/share/backgrounds/gdm-background /usr/share/backgrounds/bentobox/gdm-background.jpg 100 || true

# Method 3: Create GDM AccountsService background for current user
echo "📝 Configuring AccountsService..."
sudo mkdir -p /var/lib/AccountsService/users
CURRENT_USER_FILE="/var/lib/AccountsService/users/$USER"
if [ -f "$CURRENT_USER_FILE" ]; then
    if ! grep -q "Background=" "$CURRENT_USER_FILE"; then
        sudo tee -a "$CURRENT_USER_FILE" > /dev/null << EOF

[User]
Background=/usr/share/backgrounds/bentobox/gdm-background.jpg
EOF
        echo "   ✅ User background configured"
    else
        echo "   ✅ User background already configured"
    fi
fi

echo ""
echo "✅ GDM greeter background configuration complete!"
echo ""
echo "ℹ️  To apply changes immediately:"
echo "   sudo systemctl restart gdm3"
echo ""
echo "   Or reboot the system to see the new login screen background."
