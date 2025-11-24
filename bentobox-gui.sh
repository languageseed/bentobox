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

# Use system Python (not mise/pyenv versions) for GTK compatibility
SYSTEM_PYTHON="/usr/bin/python3"

# Check Python exists
if ! command -v "$SYSTEM_PYTHON" &> /dev/null; then
    zenity --error --text="System Python 3 is required but not installed.\n\nPlease install it first:\nsudo apt install python3"
    exit 1
fi

# Check for GTK and VTE
if ! "$SYSTEM_PYTHON" -c "import gi; gi.require_version('Gtk', '3.0'); gi.require_version('Vte', '2.91')" 2>/dev/null; then
    if zenity --question --text="Required packages not installed:\n- python3-gi\n- gir1.2-vte-2.91\n- gir1.2-gtk-3.0\n\nInstall them now?"; then
        # Open terminal to run installation with sudo
        gnome-terminal -- bash -c "echo 'Installing Bentobox GUI dependencies...'; sudo apt update && sudo apt install -y python3-gi gir1.2-vte-2.91 gir1.2-gtk-3.0 gir1.2-gdkpixbuf-2.0 python3-yaml python3-requests python3-bs4 python3-pil zenity; echo ''; echo 'Installation complete! Press Enter to close and then launch Bentobox again.'; read" || {
            zenity --error --text="Failed to install dependencies"
            exit 1
        }
        exit 0
    else
        exit 1
    fi
fi

# Check for Python dependencies
if ! "$SYSTEM_PYTHON" -c "import yaml" 2>/dev/null; then
    # Install via apt instead of pip for system-wide management
    if zenity --question --text="Python dependencies not installed.\n\nInstall them now?"; then
        gnome-terminal -- bash -c "echo 'Installing Python dependencies...'; sudo apt install -y python3-yaml python3-requests python3-bs4 python3-pil; echo ''; echo 'Installation complete! Press Enter to close and then launch Bentobox again.'; read"
        exit 0
    else
        exit 1
    fi
fi

# Launch GUI with system Python
cd "$OMAKUB_PATH" || exit 1

# Find gui.py (might be in root or install/)
if [ -f "$OMAKUB_PATH/install/gui.py" ]; then
    "$SYSTEM_PYTHON" "$OMAKUB_PATH/install/gui.py"
elif [ -f "$OMAKUB_PATH/gui.py" ]; then
    "$SYSTEM_PYTHON" "$OMAKUB_PATH/gui.py"
else
    zenity --error --text="GUI not found at $OMAKUB_PATH"
    exit 1
fi