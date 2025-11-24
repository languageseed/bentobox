#!/bin/bash

# Tela Icon Theme
# Metadata
# name: Tela Icons
# category: desktop-theme
# description: Beautiful flat icon theme with color variants
# url: https://github.com/vinceliuice/Tela-icon-theme

set -e

# Check if already installed
if [ -d "$HOME/.icons/Tela" ] || [ -d "$HOME/.local/share/icons/Tela" ]; then
    echo "✓ Tela icons already installed, skipping..."
    exit 0
fi

echo "Installing Tela Icon Theme..."

# Install dependencies
sudo apt update
sudo apt install -y git

# Create directories
mkdir -p ~/Downloads/themes
cd ~/Downloads/themes

# Clone and install
if [ -d "Tela-icon-theme" ]; then
    rm -rf "Tela-icon-theme"
fi

git clone https://github.com/vinceliuice/Tela-icon-theme.git
cd Tela-icon-theme
chmod +x install.sh
./install.sh

echo "✅ Tela icons installed successfully!"
echo "   Use GNOME Tweaks to apply the icons"

exit 0

