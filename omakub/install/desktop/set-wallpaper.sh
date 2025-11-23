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
    echo "📁 Source directory found: $WALLPAPER_SOURCE_DIR"
    WALLPAPER_COUNT=$(ls -1 "$WALLPAPER_SOURCE_DIR"/*.jpg 2>/dev/null | wc -l)
    
    if [ "$WALLPAPER_COUNT" -gt 0 ]; then
        echo "Copying $WALLPAPER_COUNT wallpapers..."
        cp -v "$WALLPAPER_SOURCE_DIR"/*.jpg "$WALLPAPER_DEST_DIR/"
        echo "✅ Wallpapers copied successfully"
    else
        echo "⚠️  No wallpaper files (.jpg) found in $WALLPAPER_SOURCE_DIR"
    fi
else
    echo "❌ ERROR: Wallpaper source directory not found!"
    echo "   Expected: $WALLPAPER_SOURCE_DIR"
    echo "   This usually means the Bentobox installation is incomplete."
    echo "   Skipping wallpaper setup..."
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
    echo "⚠️  Default wallpaper not found at: $DEFAULT_WALLPAPER"
    echo "   Wallpaper directory contents:"
    ls -la "$WALLPAPER_DEST_DIR/" 2>/dev/null || echo "   (directory is empty or doesn't exist)"
fi

echo ""
echo "Wallpaper setup complete. Files are in: $WALLPAPER_DEST_DIR"

