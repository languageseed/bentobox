#!/bin/bash

# Synergy - Commercial KVM (Keyboard/Video/Mouse) sharing software
# Share one keyboard and mouse between multiple computers
# https://symless.com/synergy

echo "Installing Synergy..."

cd /tmp

# Download Synergy (using Flatpak for easier installation)
flatpak install -y flathub com.symless.Synergy

cd -

echo "✅ Synergy installed!"
echo ""
echo "NOTE: Synergy requires a license key from https://symless.com/synergy"
echo ""
echo "Usage:"
echo "  - Launch Synergy from applications menu"
echo "  - Enter your license key"
echo "  - Configure one computer as server, others as clients"
echo "  - Share keyboard and mouse across multiple computers"
echo ""
echo "Free alternative: Use 'Barrier' instead (see app-barrier.sh)"



