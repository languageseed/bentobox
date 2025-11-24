#!/bin/bash
# Quick Fix for Terminal Font Spacing Issues

echo "🔧 Fixing terminal font configuration..."
echo ""

# Check if in desktop session
if [ -z "$DISPLAY" ] && [ -z "$WAYLAND_DISPLAY" ]; then
    echo "❌ Must be run from desktop session"
    echo "   Please run from GNOME Terminal (Ctrl+Alt+T)"
    exit 1
fi

echo "Current settings:"
echo "  Monospace font: $(gsettings get org.gnome.desktop.interface monospace-font-name)"
echo ""

# Fix 1: Use the "Mono" variant which has better spacing
echo "Applying fix 1: Switch to Nerd Font Mono variant..."
gsettings set org.gnome.desktop.interface monospace-font-name 'CaskaydiaMono Nerd Font Mono 11'

# Fix 2: Configure GNOME Terminal profile
echo "Applying fix 2: Configure GNOME Terminal profile..."
PROFILE=$(gsettings get org.gnome.Terminal.ProfilesList default | tr -d "'")
if [ -n "$PROFILE" ]; then
    gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$PROFILE/ use-system-font false
    gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$PROFILE/ font 'CaskaydiaMono Nerd Font Mono 11'
    gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$PROFILE/ cell-height-scale 1.0
    gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$PROFILE/ cell-width-scale 1.0
    echo "  ✓ Profile configured"
else
    echo "  ⚠ No default profile found"
fi

# Fix 3: Refresh font cache
echo "Applying fix 3: Refresh font cache..."
fc-cache -fv > /dev/null 2>&1
echo "  ✓ Font cache refreshed"

echo ""
echo "✅ Font configuration complete!"
echo ""
echo "Changes applied:"
echo "  • Switched to 'Nerd Font Mono' variant (better character spacing)"
echo "  • Set font size to 11"
echo "  • Configured terminal cell spacing (1.0 x 1.0)"
echo "  • Refreshed font cache"
echo ""
echo "📝 To see changes:"
echo "  1. Close this terminal window"
echo "  2. Open a new terminal (Ctrl+Alt+T)"
echo "  3. Font should now have proper spacing"
echo ""
echo "If still not fixed, try:"
echo "  • Log out and back in"
echo "  • Run: gsettings reset org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$PROFILE/ font"
echo ""

