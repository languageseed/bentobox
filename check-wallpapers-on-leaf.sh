#!/bin/bash

echo "╔══════════════════════════════════════════════════════════╗"
echo "║       BENTOBOX WALLPAPER DIAGNOSTIC                      ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""

echo "1️⃣  GIT REPOSITORY STATUS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ -d "$HOME/.local/share/omakub/.git" ]; then
    echo "✅ Git repository exists"
    cd ~/.local/share/omakub
    echo "   Current branch: $(git branch --show-current)"
    echo "   Latest commit: $(git log -1 --oneline)"
    echo "   Remote URL: $(git remote get-url origin)"
else
    echo "❌ Git repository NOT FOUND at ~/.local/share/omakub"
fi

echo ""
echo "2️⃣  OMAKUB DIRECTORY STRUCTURE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ -d "$HOME/.local/share/omakub" ]; then
    echo "✅ Omakub directory exists"
    echo "   Top-level contents:"
    ls -lh "$HOME/.local/share/omakub" | head -15
else
    echo "❌ Omakub directory NOT FOUND"
fi

echo ""
echo "3️⃣  WALLPAPER SOURCE DIRECTORY"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
WALLPAPER_SOURCE="$HOME/.local/share/omakub/wallpaper"
if [ -d "$WALLPAPER_SOURCE" ]; then
    echo "✅ Wallpaper source directory exists"
    JPG_COUNT=$(ls -1 "$WALLPAPER_SOURCE"/*.jpg 2>/dev/null | wc -l)
    echo "   JPG files found: $JPG_COUNT"
    if [ "$JPG_COUNT" -gt 0 ]; then
        echo "   Files:"
        ls -lh "$WALLPAPER_SOURCE"/*.jpg
    else
        echo "   ⚠️  No JPG files in directory!"
        echo "   Directory contents:"
        ls -la "$WALLPAPER_SOURCE"
    fi
else
    echo "❌ Wallpaper source directory NOT FOUND"
    echo "   Expected: $WALLPAPER_SOURCE"
fi

echo ""
echo "4️⃣  WALLPAPER DESTINATION DIRECTORY"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
WALLPAPER_DEST="$HOME/.local/share/backgrounds/omakub"
if [ -d "$WALLPAPER_DEST" ]; then
    echo "✅ Destination directory exists"
    DEST_COUNT=$(ls -1 "$WALLPAPER_DEST"/*.jpg 2>/dev/null | wc -l)
    echo "   JPG files: $DEST_COUNT"
    if [ "$DEST_COUNT" -gt 0 ]; then
        ls -lh "$WALLPAPER_DEST"/*.jpg
    else
        echo "   ⚠️  Directory is empty!"
    fi
else
    echo "❌ Destination directory NOT FOUND"
    echo "   Expected: $WALLPAPER_DEST"
fi

echo ""
echo "5️⃣  GDM SYSTEM BACKGROUND"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ -f "/usr/share/backgrounds/bentobox/gdm-background.jpg" ]; then
    echo "✅ GDM background file exists"
    ls -lh /usr/share/backgrounds/bentobox/gdm-background.jpg
else
    echo "❌ GDM background NOT FOUND"
    echo "   Expected: /usr/share/backgrounds/bentobox/gdm-background.jpg"
fi

echo ""
echo "6️⃣  CURRENT GNOME SETTINGS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if command -v gsettings &> /dev/null; then
    CURRENT_WP=$(gsettings get org.gnome.desktop.background picture-uri 2>/dev/null)
    echo "Current wallpaper: $CURRENT_WP"
else
    echo "⚠️  gsettings not available"
fi

echo ""
echo "╔══════════════════════════════════════════════════════════╗"
echo "║                 DIAGNOSTIC COMPLETE                      ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""
echo "📋 NEXT STEPS:"
echo "   If wallpapers are missing from source, run:"
echo "     cd ~/.local/share/omakub && git pull origin master"
echo ""
echo "   If source has wallpapers but destination doesn't, run:"
echo "     bash ~/.local/share/omakub/install/desktop/set-wallpaper.sh"

