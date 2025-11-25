#!/bin/bash

# WhiteSur GTK Theme
# Metadata
# name: WhiteSur GTK Theme
# category: desktop-theme
# description: macOS Big Sur-like GTK theme
# url: https://github.com/vinceliuice/WhiteSur-gtk-theme

set -e

# Check if already installed
if [ -d "$HOME/.themes/WhiteSur-Dark" ] || [ -d "$HOME/.local/share/themes/WhiteSur-Dark" ]; then
    echo "✓ WhiteSur GTK theme already installed, skipping..."
    exit 0
fi

echo "Installing WhiteSur GTK Theme..."

# Install dependencies
sudo apt update
sudo apt install -y sassc libglib2.0-dev-bin git

# Create directories
mkdir -p ~/Downloads/themes
cd ~/Downloads/themes

# Clone and install
if [ -d "WhiteSur-gtk-theme" ]; then
    rm -rf "WhiteSur-gtk-theme"
fi

git clone https://github.com/vinceliuice/WhiteSur-gtk-theme.git
cd WhiteSur-gtk-theme
chmod +x install.sh
./install.sh -d ~/.themes

echo "✅ WhiteSur GTK theme installed successfully!"
echo ""
echo "📝 To apply the theme:"
echo "   1. Open GNOME Tweaks (Applications → Tweaks)"
echo "   2. Go to Appearance section"
echo "   3. Select 'WhiteSur-Dark' under Applications"
echo ""
echo "💡 If you don't see the theme in GNOME Tweaks:"
echo "   • Restart GNOME Tweaks or logout/login"
echo "   • For shell themes, install User Themes extension first"
echo ""
echo "🔧 Apply via command line:"
echo "   gsettings set org.gnome.desktop.interface gtk-theme 'WhiteSur-Dark'"

exit 0

