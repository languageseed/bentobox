#!/bin/bash

# Set custom wallpaper - copy to persistent location first
echo "Setting up wallpaper..."

# Source wallpaper from Bentobox
SOURCE_WALLPAPER="$OMAKUB_PATH/wallpaper/pexels-pok-rie-33563-2049422.jpg"
WALLPAPER_NAME="bentobox-default.jpg"

# Create persistent wallpaper directories
PICTURES_WALLPAPERS="$HOME/Pictures/Wallpapers"
BACKGROUNDS_DIR="$HOME/.local/share/backgrounds"

mkdir -p "$PICTURES_WALLPAPERS"
mkdir -p "$BACKGROUNDS_DIR"

if [ ! -f "$SOURCE_WALLPAPER" ]; then
    echo "❌ ERROR: Source wallpaper not found"
    echo "   Checking wallpaper directory:"
    ls -la "$OMAKUB_PATH/wallpaper/" 2>/dev/null || echo "   Directory doesn't exist!"
    echo "⚠️  Continuing without wallpaper..."
    exit 0
fi

echo "✅ Source wallpaper found"
echo "📦 Copying wallpapers to persistent locations..."

# Copy to user Pictures directory (primary persistent location)
cp "$SOURCE_WALLPAPER" "$PICTURES_WALLPAPERS/$WALLPAPER_NAME"
echo "   ✓ Copied to ~/Pictures/Wallpapers/"

# Copy to backgrounds directory (used by GNOME)
cp "$SOURCE_WALLPAPER" "$BACKGROUNDS_DIR/$WALLPAPER_NAME"
echo "   ✓ Copied to ~/.local/share/backgrounds/"

# Copy all wallpapers from the collection
echo "📦 Copying Bentobox wallpaper collection..."
if [ -d "$OMAKUB_PATH/wallpaper" ]; then
    WALLPAPER_COUNT=0
    for wallpaper in "$OMAKUB_PATH/wallpaper"/*.jpg "$OMAKUB_PATH/wallpaper"/*.png; do
        if [ -f "$wallpaper" ]; then
            filename=$(basename "$wallpaper")
            cp "$wallpaper" "$PICTURES_WALLPAPERS/$filename"
            cp "$wallpaper" "$BACKGROUNDS_DIR/$filename"
            ((WALLPAPER_COUNT++))
        fi
    done
    echo "   ✓ Copied $WALLPAPER_COUNT wallpapers"
fi

# Use the persistent location for setting wallpaper
WALLPAPER_PATH="$PICTURES_WALLPAPERS/$WALLPAPER_NAME"

echo "🎨 Setting wallpaper..."
gsettings set org.gnome.desktop.background picture-uri "file://$WALLPAPER_PATH"
gsettings set org.gnome.desktop.background picture-uri-dark "file://$WALLPAPER_PATH"
gsettings set org.gnome.desktop.background picture-options 'zoom'

echo "✅ Wallpaper set successfully!"
echo "   📁 Saved to: ~/Pictures/Wallpapers/"
echo "   🔄 Wallpapers will persist across updates"

