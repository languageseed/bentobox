#!/bin/bash

# Set custom wallpaper directly from repository - no copying needed
echo "Setting up wallpaper..."

# Use wallpaper directly from repository
WALLPAPER_PATH="$HOME/.local/share/omakub/wallpaper/pexels-pok-rie-33563-2049422.jpg"

if [ ! -f "$WALLPAPER_PATH" ]; then
    echo "❌ ERROR: Wallpaper not found at $WALLPAPER_PATH"
    echo "   Checking wallpaper directory:"
    ls -la "$HOME/.local/share/omakub/wallpaper/" 2>/dev/null || echo "   Directory doesn't exist!"
    echo "⚠️  Continuing without wallpaper..."
    exit 0
fi

echo "✅ Wallpaper found: $WALLPAPER_PATH"
echo "🎨 Setting wallpaper..."

gsettings set org.gnome.desktop.background picture-uri "file://$WALLPAPER_PATH"
gsettings set org.gnome.desktop.background picture-uri-dark "file://$WALLPAPER_PATH"
gsettings set org.gnome.desktop.background picture-options 'zoom'

echo "✅ Wallpaper set successfully!"

