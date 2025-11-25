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
echo ""
echo "📝 To apply the theme:"
echo "   1. Open GNOME Tweaks (Applications → Tweaks)"
echo "   2. Go to Appearance section"
echo "   3. Select 'Orchis-Dark' under Applications"
echo ""
echo "💡 If you don't see the theme in GNOME Tweaks:"
echo "   • Restart GNOME Tweaks or logout/login"
echo "   • For shell themes, install User Themes extension first"
echo ""
echo "🔧 Apply via command line:"
echo "   gsettings set org.gnome.desktop.interface gtk-theme 'Orchis-Dark'"

exit 0

