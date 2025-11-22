#!/bin/bash

# Set GDM3 Login Greeter Background (not just lock screen)
# This modifies the actual GDM theme to show custom wallpaper

echo "Setting GDM3 login greeter background..."

WALLPAPER_SOURCE="$HOME/.local/share/backgrounds/omakub/pexels-pok-rie-33563-2049422.jpg"

# Check if wallpaper exists
if [ ! -f "$WALLPAPER_SOURCE" ]; then
    echo "⚠️  Wallpaper not found, skipping..."
    exit 0
fi

# Copy wallpaper to system location
echo 'labadmin' | sudo -S mkdir -p /usr/share/backgrounds/bentobox
echo 'labadmin' | sudo -S cp "$WALLPAPER_SOURCE" /usr/share/backgrounds/bentobox/gdm-background.jpg
echo 'labadmin' | sudo -S chmod 644 /usr/share/backgrounds/bentobox/gdm-background.jpg

# Method 1: Extract and modify GDM theme
GDM_THEME_DIR="/usr/share/gnome-shell/theme"
GDM_THEME_FILE="$GDM_THEME_DIR/ubuntu.css"

if [ -f "$GDM_THEME_FILE" ]; then
    # Backup original if not already backed up
    if [ ! -f "$GDM_THEME_FILE.bak" ]; then
        echo 'labadmin' | sudo -S cp "$GDM_THEME_FILE" "$GDM_THEME_FILE.bak"
    fi
    
    # Add/modify background in CSS
    echo 'labadmin' | sudo -S tee "$GDM_THEME_FILE" > /dev/null << 'EOF'
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
fi

# Method 2: Use alternatives system
echo 'labadmin' | sudo -S update-alternatives --install /usr/share/backgrounds/gdm-background /usr/share/backgrounds/gdm-background /usr/share/backgrounds/bentobox/gdm-background.jpg 100 || true

# Method 3: Create GDM AccountsService background
echo 'labadmin' | sudo -S mkdir -p /var/lib/AccountsService/users
if [ -f "/var/lib/AccountsService/users/labadmin" ]; then
    if ! grep -q "Background=" "/var/lib/AccountsService/users/labadmin"; then
        echo 'labadmin' | sudo -S tee -a /var/lib/AccountsService/users/labadmin > /dev/null << EOF

[User]
Background=/usr/share/backgrounds/bentobox/gdm-background.jpg
EOF
    fi
fi

# Restart GDM to apply changes
echo "✅ GDM background configuration complete!"
echo ""
echo "To apply changes, restart GDM service:"
echo "  sudo systemctl restart gdm3"
echo ""
echo "Or reboot the system:"
echo "  sudo reboot"

