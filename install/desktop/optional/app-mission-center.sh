#!/bin/bash

# Install Mission Center - System monitoring application
# https://missioncenter.io/

# Exit if already installed via Flatpak
if flatpak list 2>/dev/null | grep -q "io.missioncenter.MissionCenter"; then
    echo "✓ Mission Center already installed, skipping..."
    exit 0
fi

echo "Installing Mission Center..."

# Install via Flatpak
flatpak install -y flathub io.missioncenter.MissionCenter || {
    echo "❌ Failed to install Mission Center via Flatpak"
    echo "   Make sure Flatpak is installed and Flathub is added"
    exit 0
}

echo "✅ Mission Center installed successfully"
echo ""
echo "💡 Launch from Applications or run: flatpak run io.missioncenter.MissionCenter"
echo ""

exit 0

