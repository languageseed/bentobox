#!/bin/bash

# Orchis GTK Theme
# Metadata
# name: Orchis Theme
# category: desktop-theme
# description: Modern dark GTK theme with rounded corners
# url: https://github.com/vinceliuice/Orchis-theme

set -e

# Check if already installed
if [ -d "$HOME/.themes/Orchis-Dark" ] || [ -d "$HOME/.local/share/themes/Orchis-Dark" ]; then
    echo "✓ Orchis theme already installed, skipping..."
    exit 0
fi

echo "Installing Orchis Theme..."

# Install dependencies
sudo apt update
sudo apt install -y sassc libglib2.0-dev-bin git

# Create directories
mkdir -p ~/Downloads/themes
cd ~/Downloads/themes

# Clone and install
if [ -d "Orchis-theme" ]; then
    rm -rf "Orchis-theme"
fi

git clone https://github.com/vinceliuice/Orchis-theme.git
cd Orchis-theme
chmod +x install.sh
./install.sh -c dark

echo "✅ Orchis theme installed successfully!"
echo "   Use GNOME Tweaks to apply the theme"

exit 0

