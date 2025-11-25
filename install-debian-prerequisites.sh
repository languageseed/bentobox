#!/bin/bash
# Bentobox Prerequisites Installer for Debian 13
# Run this before installing Bentobox

set -e

echo "╔════════════════════════════════════════════════════════════╗"
echo "║   Bentobox Prerequisites Installer for Debian 13          ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# Check if running on Debian
if [ ! -f /etc/os-release ]; then
    echo "❌ Cannot detect OS"
    exit 1
fi

. /etc/os-release

if [ "$ID" != "debian" ]; then
    echo "❌ This script is for Debian only"
    echo "   Detected: $PRETTY_NAME"
    exit 1
fi

if [ "${VERSION_ID%%.*}" -lt 13 ]; then
    echo "⚠️  Warning: Debian 13+ recommended"
    echo "   Detected: Debian $VERSION_ID"
    read -p "   Continue anyway? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

echo "✓ Detected: $PRETTY_NAME"
echo ""

# Check what's already installed
echo "Checking current system..."
MISSING=()

for pkg in python3-pip python3-yaml build-essential gir1.2-gtk-3.0 gir1.2-vte-2.91 gir1.2-gdkpixbuf-2.0; do
    if ! dpkg -l | grep -q "^ii  $pkg "; then
        MISSING+=("$pkg")
    fi
done

if [ ${#MISSING[@]} -eq 0 ]; then
    echo "✓ All prerequisites already installed!"
    echo ""
    echo "You can now install Bentobox:"
    echo "  Terminal: wget -qO- https://raw.githubusercontent.com/languageseed/bentobox/master/boot.sh | bash"
    echo "  GUI:      wget -qO- https://raw.githubusercontent.com/languageseed/bentobox/master/boot-gui.sh | bash"
    exit 0
fi

echo "Missing packages: ${#MISSING[@]}"
for pkg in "${MISSING[@]}"; do
    echo "  - $pkg"
done
echo ""

read -p "Install missing packages? (Y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Nn]$ ]]; then
    echo "Installation cancelled."
    exit 1
fi

echo ""
echo "📦 Updating package lists..."
sudo apt update

echo ""
echo "📦 Installing prerequisites..."
echo ""

# Install core requirements
echo "Installing core requirements..."
sudo apt install -y python3-pip python3-yaml build-essential

echo ""
echo "Installing GUI requirements..."
sudo apt install -y gir1.2-gtk-3.0 gir1.2-vte-2.91 gir1.2-gdkpixbuf-2.0

echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║              ✅ Prerequisites Installed!                   ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""
echo "Next steps:"
echo ""
echo "1. Install Bentobox (choose one):"
echo ""
echo "   GUI Installer (recommended):"
echo "   wget -qO- https://raw.githubusercontent.com/languageseed/bentobox/master/boot-gui.sh | bash"
echo ""
echo "   Terminal Installer:"
echo "   wget -qO- https://raw.githubusercontent.com/languageseed/bentobox/master/boot.sh | bash"
echo ""
echo "2. Follow the prompts to customize your installation"
echo ""
echo "3. Reboot when installation completes"
echo ""
echo "Enjoy your Bentobox development environment! 🎉"

