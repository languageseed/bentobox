#!/bin/bash
# Install Bentobox GUI to system

set -e

OMAKUB_PATH="${OMAKUB_PATH:-$HOME/.local/share/omakub}"

echo "📦 Installing Bentobox GUI..."

# Detect distribution
if [ -f /etc/os-release ]; then
    . /etc/os-release
    DISTRO_ID="$ID"
else
    DISTRO_ID="unknown"
fi

# Clean up any conflicting Warp repository files that may cause apt warnings
if [ -f /etc/apt/sources.list.d/warp.list ] || [ -f /etc/apt/sources.list.d/warpdotdev.list ]; then
    echo "⚠️  Cleaning up conflicting Warp repository configuration..."
    sudo rm -f /etc/apt/sources.list.d/warp.list
    sudo rm -f /etc/apt/sources.list.d/warpdotdev.list
    sudo rm -f /usr/share/keyrings/warp.gpg
    sudo rm -f /etc/apt/trusted.gpg.d/warpdotdev.gpg
fi

# Debian-specific: Install additional prerequisites
if [[ "$DISTRO_ID" == "debian" ]] || [[ "$DISTRO_ID" == "raspbian" ]]; then
    echo "📦 Installing Debian prerequisites..."
    # Check and install missing prerequisites
    DEBIAN_PREREQS="python3-pip build-essential"
    MISSING_PREREQS=()
    
    for pkg in $DEBIAN_PREREQS; do
        if ! dpkg -l | grep -q "^ii  $pkg "; then
            MISSING_PREREQS+=("$pkg")
        fi
    done
    
    if [ ${#MISSING_PREREQS[@]} -gt 0 ]; then
        echo "   Installing: ${MISSING_PREREQS[*]}"
        sudo apt install -y "${MISSING_PREREQS[@]}"
    else
        echo "   ✓ All Debian prerequisites already installed"
    fi
fi

# Install system dependencies
echo "Installing GTK dependencies..."

# Update apt, but don't fail if there are repository warnings
sudo apt update 2>&1 | grep -v "Conflicting values set for option Signed-By" | grep -v "The list of sources could not be read" || true

sudo apt install -y python3-gi python3-gi-cairo gir1.2-gtk-3.0 gir1.2-vte-2.91 gir1.2-gdkpixbuf-2.0 zenity

# Install Python dependencies (system packages)
echo "Installing Python dependencies..."
sudo apt install -y python3-yaml python3-requests python3-bs4 python3-pil

# Copy GUI launcher to /usr/local/bin
echo "Installing launcher..."
sudo cp "$OMAKUB_PATH/bentobox-gui.sh" /usr/local/bin/bentobox-gui
sudo chmod +x /usr/local/bin/bentobox-gui

# Update desktop file path
sed "s|Exec=.*|Exec=/usr/local/bin/bentobox-gui|" "$OMAKUB_PATH/bentobox-installer.desktop" > /tmp/bentobox-installer.desktop

# Install desktop file
echo "Installing desktop launcher..."
sudo desktop-file-install /tmp/bentobox-installer.desktop
rm /tmp/bentobox-installer.desktop

# Update desktop database
sudo update-desktop-database

echo ""
echo "✅ Bentobox GUI installed successfully!"
echo ""
echo "You can now launch it from:"
echo "  • Applications menu → System → Bentobox Installer"
echo "  • Terminal: bentobox-gui"
echo ""

