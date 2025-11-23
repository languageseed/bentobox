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
    
    # Check if wallpapers exist
    if ls "$WALLPAPER_SOURCE_DIR"/*.jpg >/dev/null 2>&1; then
        WALLPAPER_COUNT=$(ls -1 "$WALLPAPER_SOURCE_DIR"/*.jpg | wc -l)
        echo "📋 Copying $WALLPAPER_COUNT wallpapers..."
        
        # Copy with error checking
        if cp "$WALLPAPER_SOURCE_DIR"/*.jpg "$WALLPAPER_DEST_DIR/"; then
            echo "✅ Wallpapers copied successfully to $WALLPAPER_DEST_DIR"
            ls -lh "$WALLPAPER_DEST_DIR"/*.jpg
        else
            echo "❌ ERROR: Failed to copy wallpapers!"
            exit 1
        fi
    else
        echo "❌ ERROR: No wallpaper files (.jpg) found in $WALLPAPER_SOURCE_DIR"
        echo "   Directory contents:"
        ls -la "$WALLPAPER_SOURCE_DIR/"
        exit 1
    fi
else
    echo "❌ ERROR: Wallpaper source directory not found!"
    echo "   Expected: $WALLPAPER_SOURCE_DIR"
    echo "   Checking if omakub directory exists:"
    ls -ld "$HOME/.local/share/omakub" 2>/dev/null || echo "   ❌ Omakub directory missing!"
    echo ""
    echo "   This usually means the Bentobox installation is incomplete."
    echo "   The repository should have been cloned to ~/.local/share/omakub"
    exit 1
fi

# Set default wallpaper
DEFAULT_WALLPAPER="$WALLPAPER_DEST_DIR/pexels-pok-rie-33563-2049422.jpg"

if [ -f "$DEFAULT_WALLPAPER" ]; then
    echo ""
    echo "🎨 Setting default wallpaper..."
    gsettings set org.gnome.desktop.background picture-uri "file://$DEFAULT_WALLPAPER"
    gsettings set org.gnome.desktop.background picture-uri-dark "file://$DEFAULT_WALLPAPER"
    gsettings set org.gnome.desktop.background picture-options 'zoom'
    echo "✅ Default wallpaper set: pexels-pok-rie-33563-2049422.jpg"
else
    echo ""
    echo "❌ ERROR: Default wallpaper not found!"
    echo "   Expected: $DEFAULT_WALLPAPER"
    echo "   Destination directory contents:"
    ls -la "$WALLPAPER_DEST_DIR/" 2>/dev/null || echo "   (directory is empty or doesn't exist)"
    exit 1
fi

echo ""
echo "✅ Wallpaper setup complete!"
echo "📁 Wallpapers location: $WALLPAPER_DEST_DIR"

