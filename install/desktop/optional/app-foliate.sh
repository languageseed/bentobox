#!/bin/bash

# Install Foliate - Modern eBook reader for Linux
# https://johnfactotum.github.io/foliate/

# Exit if already installed via Flatpak
if flatpak list 2>/dev/null | grep -q "com.github.johnfactotum.Foliate"; then
    echo "✓ Foliate already installed, skipping..."
    exit 0
fi

echo "Installing Foliate..."

# Install via Flatpak
flatpak install -y flathub com.github.johnfactotum.Foliate || {
    echo "❌ Failed to install Foliate via Flatpak"
    echo "   Make sure Flatpak is installed and Flathub is added"
    exit 0
}

echo "✅ Foliate installed successfully"
echo ""
echo "💡 Supported formats: EPUB, Mobipocket, Kindle, FB2, CBZ, PDF"
echo "   Launch from Applications or run: flatpak run com.github.johnfactotum.Foliate"
echo ""

exit 0

