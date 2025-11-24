#!/bin/bash
# Install Bentobox GUI to system

set -e

OMAKUB_PATH="${OMAKUB_PATH:-$HOME/.local/share/omakub}"

echo "📦 Installing Bentobox GUI..."

# Install system dependencies
echo "Installing GTK dependencies..."
sudo apt update
sudo apt install -y python3-gi gir1.2-gtk-3.0 gir1.2-vte-2.91 zenity

# Install Python dependencies
echo "Installing Python dependencies..."
python3 -m pip install --user pyyaml 2>/dev/null || {
    echo "Note: PyYAML installation skipped (will install on first run if needed)"
}

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

