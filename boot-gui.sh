#!/bin/bash
# Bentobox GUI Installer Bootstrap
# Downloads Bentobox and launches the GUI installer

set -e

echo "🎨 Bentobox GUI Installer"
echo "=========================="
echo ""

# Check if running on Ubuntu 24.04+ or Debian 13+
if [ -f /etc/os-release ]; then
    . /etc/os-release
    
    case "$ID" in
        ubuntu|pop|elementary|mint|neon)
            if [[ "${VERSION_ID%%.*}" -lt 24 ]]; then
                echo "❌ This installer requires Ubuntu 24.04 or later"
                echo "   Detected: $PRETTY_NAME"
                exit 1
            fi
            ;;
        debian|raspbian)
            if [[ "${VERSION_ID%%.*}" -lt 13 ]]; then
                echo "❌ This installer requires Debian 13 (Trixie) or later"
                echo "   Detected: $PRETTY_NAME"
                echo "   Note: Debian 12 may work but is not officially supported"
                exit 1
            fi
            ;;
        *)
            echo "❌ Unsupported distribution: $PRETTY_NAME"
            echo ""
            echo "Bentobox supports:"
            echo "  • Ubuntu 24.04+ (and derivatives)"
            echo "  • Debian 13+ (Trixie)"
            exit 1
            ;;
    esac
fi

# Check for graphical environment
if [ -z "$DISPLAY" ] && [ -z "$WAYLAND_DISPLAY" ]; then
    echo "❌ No graphical display detected"
    echo "   The GUI installer requires a desktop environment"
    echo ""
    echo "💡 For terminal installation, use:"
    echo "   wget -qO- https://raw.githubusercontent.com/languageseed/bentobox/master/boot.sh | bash"
    exit 1
fi

echo "📦 Downloading Bentobox..."
# Remove existing installation if present
if [ -d "$HOME/.local/share/omakub" ]; then
    echo "   Found existing installation, updating..."
    cd "$HOME/.local/share/omakub"
    git pull --quiet 2>/dev/null || {
        echo "   Removing old installation and downloading fresh copy..."
        cd "$HOME"
        rm -rf "$HOME/.local/share/omakub"
        git clone --quiet https://github.com/languageseed/bentobox.git "$HOME/.local/share/omakub"
    }
else
    mkdir -p "$HOME/.local/share"
    git clone --quiet https://github.com/languageseed/bentobox.git "$HOME/.local/share/omakub"
fi

cd "$HOME/.local/share/omakub"

echo "✅ Download complete"
echo ""
echo "🔧 Installing GUI dependencies..."
bash install-gui.sh

echo ""
echo "🚀 Launching Bentobox GUI..."
echo ""

# Launch GUI
bentobox-gui &

echo "✨ GUI launched successfully!"
echo ""
echo "📝 Next steps:"
echo "   1. Configure your preferences in the GUI"
echo "   2. Click 'Start Installation' when ready"
echo "   3. The GUI is also available in your Applications menu"
echo ""

