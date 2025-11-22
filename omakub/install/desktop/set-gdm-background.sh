#!/bin/bash

# Set GDM (login screen) background to match user wallpaper
# Ubuntu 24.04 requires gresource extraction and recompilation

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

# Create temporary workspace
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

GRESOURCE="/usr/share/gnome-shell/gnome-shell-theme.gresource"

# Extract gdm.css from gresource
gresource extract $GRESOURCE /org/gnome/shell/theme/gdm.css > gdm.css 2>/dev/null || echo "" > gdm.css

# Add custom background CSS
cat >> gdm.css << 'EOF'

/* Bentobox GDM Background */
#lockDialogGroup {
  background: url(file:///usr/share/backgrounds/bentobox/login-background.jpg);
  background-size: cover !important;
  background-position: center !important;
  background-repeat: no-repeat !important;
}

stage {
  background: url(file:///usr/share/backgrounds/bentobox/login-background.jpg);
  background-size: cover;
}
EOF

# Create gresource XML
cat > theme.gresource.xml << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<gresources>
  <gresource prefix="/org/gnome/shell/theme">
    <file>gdm.css</file>
  </gresource>
</gresources>
EOF

# Compile new gresource
glib-compile-resources theme.gresource.xml

# Install custom gresource
sudo cp theme.gresource /usr/share/gnome-shell/gdm-theme.gresource

# Set as default GDM theme (Ubuntu 24.04)
sudo update-alternatives --install /usr/share/gnome-shell/gdm-theme.gresource gdm-theme.gresource /usr/share/gnome-shell/gdm-theme.gresource 100

# Clean up
cd ~
rm -rf "$TEMP_DIR"

echo "✅ GDM login screen background set!"
echo "   Background: /usr/share/backgrounds/bentobox/login-background.jpg"
echo ""
echo "Note: Restart GDM to see changes: sudo systemctl restart gdm3 (or reboot)"

