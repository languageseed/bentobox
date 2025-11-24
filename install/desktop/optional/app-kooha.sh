#!/bin/bash

# Install Kooha - Simple screen recorder
# https://github.com/SeaDve/Kooha

# Exit if already installed via Flatpak
if flatpak list 2>/dev/null | grep -q "io.github.seadve.Kooha"; then
    echo "✓ Kooha already installed, skipping..."
    exit 0
fi

echo "Installing Kooha..."

# Install via Flatpak
flatpak install -y flathub io.github.seadve.Kooha || {
    echo "❌ Failed to install Kooha via Flatpak"
    echo "   Make sure Flatpak is installed and Flathub is added"
    exit 0
}

echo "✅ Kooha installed successfully"
echo ""
echo "💡 Kooha features:"
echo "   • Record screen, window, or selection"
echo "   • Audio recording support"
echo "   • WebM, MP4, GIF, and Matroska formats"
echo "   • Simple and intuitive interface"
echo ""
echo "   Launch from Applications or run: flatpak run io.github.seadve.Kooha"
echo ""

exit 0

