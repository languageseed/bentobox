#!/bin/bash

# Barrier - Open source KVM (Keyboard/Video/Mouse) sharing software
# Free alternative to Synergy that shares keyboard and mouse between multiple computers
# https://github.com/debauchee/barrier

echo "Installing Barrier (open source Synergy alternative)..."

cd /tmp

# Get latest release version
BARRIER_VERSION=$(curl -s "https://api.github.com/repos/debauchee/barrier/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')

# Download the .deb package
wget -O barrier.deb "https://github.com/debauchee/barrier/releases/download/v${BARRIER_VERSION}/barrier_${BARRIER_VERSION}_ubuntu_24.04_amd64.deb"

# Install
sudo apt install -y ./barrier.deb

# Cleanup
rm barrier.deb

cd -

echo "✅ Barrier installed!"
echo ""
echo "Usage:"
echo "  - Run 'barrier' to launch the GUI"
echo "  - Configure one computer as server, others as clients"
echo "  - Share keyboard and mouse across multiple computers"



