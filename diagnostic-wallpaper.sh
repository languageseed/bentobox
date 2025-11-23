#!/bin/bash

echo "🔍 Wallpaper Installation Diagnostic"
echo "===================================="
echo ""

echo "1️⃣  Checking Bentobox installation directory:"
if [ -d "$HOME/.local/share/omakub" ]; then
    echo "   ✅ $HOME/.local/share/omakub exists"
    ls -lah "$HOME/.local/share/omakub" | head -10
else
    echo "   ❌ $HOME/.local/share/omakub NOT FOUND!"
fi

echo ""
echo "2️⃣  Checking wallpaper source directory:"
if [ -d "$HOME/.local/share/omakub/wallpaper" ]; then
    echo "   ✅ $HOME/.local/share/omakub/wallpaper exists"
    WALLPAPER_COUNT=$(ls -1 "$HOME/.local/share/omakub/wallpaper"/*.jpg 2>/dev/null | wc -l)
    echo "   📊 Wallpaper files found: $WALLPAPER_COUNT"
    ls -lah "$HOME/.local/share/omakub/wallpaper"/*.jpg 2>/dev/null | head -10
else
    echo "   ❌ $HOME/.local/share/omakub/wallpaper NOT FOUND!"
fi

echo ""
echo "3️⃣  Checking wallpaper destination directory:"
if [ -d "$HOME/.local/share/backgrounds/omakub" ]; then
    echo "   ✅ $HOME/.local/share/backgrounds/omakub exists"
    DEST_COUNT=$(ls -1 "$HOME/.local/share/backgrounds/omakub"/*.jpg 2>/dev/null | wc -l)
    echo "   📊 Wallpaper files in destination: $DEST_COUNT"
    ls -lah "$HOME/.local/share/backgrounds/omakub"/*.jpg 2>/dev/null | head -10
else
    echo "   ❌ $HOME/.local/share/backgrounds/omakub NOT FOUND!"
fi

echo ""
echo "4️⃣  Checking GDM background location:"
if [ -f "/usr/share/backgrounds/bentobox/gdm-background.jpg" ]; then
    echo "   ✅ GDM background exists"
    ls -lah /usr/share/backgrounds/bentobox/gdm-background.jpg
else
    echo "   ❌ GDM background NOT FOUND!"
fi

echo ""
echo "5️⃣  Current GNOME wallpaper setting:"
gsettings get org.gnome.desktop.background picture-uri 2>/dev/null || echo "   ❌ Could not read wallpaper setting"

echo ""
echo "===================================="
echo "📋 Diagnostic complete!"



