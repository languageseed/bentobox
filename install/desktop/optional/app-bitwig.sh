#!/bin/bash

# Install Bitwig Studio - Modern music production DAW
# https://www.bitwig.com/

# Exit if already installed via Flatpak
if flatpak list 2>/dev/null | grep -q "com.bitwig.BitwigStudio"; then
    echo "✓ Bitwig Studio already installed, skipping..."
    exit 0
fi

# Also check for system installation
if command -v bitwig-studio &> /dev/null; then
    echo "✓ Bitwig Studio already installed, skipping..."
    exit 0
fi

echo "Installing Bitwig Studio..."

# Install via Flatpak (preferred method for latest version)
flatpak install -y flathub com.bitwig.BitwigStudio || {
    echo "❌ Failed to install Bitwig Studio via Flatpak"
    echo "   Make sure Flatpak is installed and Flathub is added"
    exit 0
}

echo "✅ Bitwig Studio installed successfully"
echo ""
echo "💡 Bitwig Studio features:"
echo "   • Modern music production and performance"
echo "   • Advanced clip launching and arrangement"
echo "   • Hybrid modular environment"
echo "   • The Grid - modular synthesis environment"
echo "   • Built-in instruments and effects"
echo "   • Free 30-day trial (full features)"
echo ""
echo "   Launch from Applications or run: flatpak run com.bitwig.BitwigStudio"
echo ""
echo "📝 Note: First launch requires registration for 30-day trial"
echo "   Visit: https://www.bitwig.com/ to create account"
echo ""

exit 0

