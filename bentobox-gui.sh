#!/bin/bash
# Bentobox GUI Launcher

# Set OMAKUB_PATH
export OMAKUB_PATH="${OMAKUB_PATH:-$HOME/.local/share/omakub}"

# Check if running in graphical session
if [ -z "$DISPLAY" ] && [ -z "$WAYLAND_DISPLAY" ]; then
    echo "❌ No display detected. GUI requires a graphical session."
    echo "   Run this from the desktop, not over SSH."
    exit 1
fi

# Check Python and GTK dependencies
if ! command -v python3 &> /dev/null; then
    zenity --error --text="Python 3 is required but not installed.\n\nPlease install it first:\nsudo apt install python3"
    exit 1
fi

# Check for GTK and VTE
if ! python3 -c "import gi; gi.require_version('Gtk', '3.0'); gi.require_version('Vte', '2.91')" 2>/dev/null; then
    if zenity --question --text="Required packages not installed:\n- python3-gi\n- gir1.2-vte-2.91\n\nInstall them now?"; then
        pkexec apt install -y python3-gi gir1.2-vte-2.91 gir1.2-gtk-3.0 || {
            zenity --error --text="Failed to install dependencies"
            exit 1
        }
    else
        exit 1
    fi
fi

# Check for PyYAML
if ! python3 -c "import yaml" 2>/dev/null; then
    python3 -m pip install --user pyyaml
fi

# Launch GUI
cd "$OMAKUB_PATH" || exit 1

# Find gui.py (might be in root or install/)
if [ -f "$OMAKUB_PATH/install/gui.py" ]; then
    python3 "$OMAKUB_PATH/install/gui.py"
elif [ -f "$OMAKUB_PATH/gui.py" ]; then
    python3 "$OMAKUB_PATH/gui.py"
else
    zenity --error --text="GUI not found at $OMAKUB_PATH"
    exit 1
fi

