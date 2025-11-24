#!/bin/bash
# Quick Bentobox GUI Test
# Run this from the GNOME desktop terminal

echo "🧪 Testing Bentobox GUI..."
echo ""

# Check if we're in a graphical session
if [ -z "$DISPLAY" ] && [ -z "$WAYLAND_DISPLAY" ]; then
    echo "❌ ERROR: No graphical session detected"
    echo ""
    echo "This must be run from the GNOME desktop, not over SSH."
    echo ""
    echo "Steps:"
    echo "  1. Log into the GNOME desktop on this machine"
    echo "  2. Press Ctrl+Alt+T to open a terminal"
    echo "  3. Run: bash ~/.local/share/omakub/test-gui.sh"
    exit 1
fi

echo "✅ Graphical session detected"

# Check dependencies
echo "Checking dependencies..."

if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 not found"
    exit 1
fi
echo "  ✓ Python 3"

if ! python3 -c "import gi" 2>/dev/null; then
    echo "❌ python3-gi not installed"
    echo "   Run: sudo apt install python3-gi"
    exit 1
fi
echo "  ✓ python3-gi"

if ! python3 -c "import gi; gi.require_version('Gtk', '3.0')" 2>/dev/null; then
    echo "❌ GTK 3 not found"
    echo "   Run: sudo apt install gir1.2-gtk-3.0"
    exit 1
fi
echo "  ✓ GTK 3"

if ! python3 -c "import gi; gi.require_version('Vte', '2.91')" 2>/dev/null; then
    echo "❌ VTE not found"
    echo "   Run: sudo apt install gir1.2-vte-2.91"
    exit 1
fi
echo "  ✓ VTE terminal widget"

if ! python3 -c "import yaml" 2>/dev/null; then
    echo "⚠️  PyYAML not installed (will install automatically)"
else
    echo "  ✓ PyYAML"
fi

echo ""
echo "✅ All dependencies satisfied!"
echo ""
echo "🚀 Launching Bentobox GUI..."
echo ""

bentobox-gui

