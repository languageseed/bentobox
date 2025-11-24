#!/bin/bash

# WhiteSur Icon Theme
# Metadata
# name: WhiteSur Icons
# category: desktop-theme
# description: macOS Big Sur-like icon theme
# url: https://github.com/vinceliuice/WhiteSur-icon-theme

set -e

# Check if already installed
if [ -d "$HOME/.icons/WhiteSur" ] || [ -d "$HOME/.local/share/icons/WhiteSur" ]; then
    echo "✓ WhiteSur icons already installed, skipping..."
    exit 0
fi

echo "Installing WhiteSur Icon Theme..."

# Install dependencies
sudo apt update
sudo apt install -y git

# Create directories
mkdir -p ~/Downloads/themes
cd ~/Downloads/themes

# Clone and install
if [ -d "WhiteSur-icon-theme" ]; then
    rm -rf "WhiteSur-icon-theme"
fi

git clone https://github.com/vinceliuice/WhiteSur-icon-theme.git
cd WhiteSur-icon-theme
chmod +x install.sh
./install.sh -d ~/.icons

echo "✅ WhiteSur icons installed successfully!"
echo "   Use GNOME Tweaks to apply the icons"

exit 0

