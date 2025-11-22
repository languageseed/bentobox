#!/bin/bash

# Set custom wallpaper from wallpaper directory
# This script copies wallpapers and sets the default

echo "Setting up custom wallpapers..."

# Create wallpapers directory in user's home
WALLPAPER_DEST_DIR="$HOME/.local/share/backgrounds/omakub"
mkdir -p "$WALLPAPER_DEST_DIR"

# Copy all wallpapers from omakub installation
WALLPAPER_SOURCE_DIR="$HOME/.local/share/omakub/wallpaper"
if [ -d "$WALLPAPER_SOURCE_DIR" ]; then
    echo "Copying wallpapers..."
    cp -r "$WALLPAPER_SOURCE_DIR"/*.jpg "$WALLPAPER_DEST_DIR/" 2>/dev/null || true
fi

# Set default wallpaper
DEFAULT_WALLPAPER="$WALLPAPER_DEST_DIR/pexels-pok-rie-33563-2049422.jpg"

if [ -f "$DEFAULT_WALLPAPER" ]; then
    echo "Setting default wallpaper..."
    gsettings set org.gnome.desktop.background picture-uri "file://$DEFAULT_WALLPAPER"
    gsettings set org.gnome.desktop.background picture-uri-dark "file://$DEFAULT_WALLPAPER"
    gsettings set org.gnome.desktop.background picture-options 'zoom'
    echo "✅ Default wallpaper set: pexels-pok-rie-33563-2049422.jpg"
else
    echo "⚠️  Default wallpaper not found, skipping..."
fi

echo ""
echo "Additional wallpapers available in: $WALLPAPER_DEST_DIR"
echo "You can change wallpaper anytime through Settings > Appearance > Background"

