#!/bin/bash

# Install REAPER - Digital Audio Workstation (DAW)
# https://www.reaper.fm/

# Exit if already installed
if command -v reaper &> /dev/null; then
    echo "✓ REAPER already installed, skipping..."
    exit 0
fi

echo "Installing REAPER..."

# Download latest Linux version
cd /tmp
wget -q "https://www.reaper.fm/files/7.x/reaper_linux_x86_64.tar.xz" -O reaper.tar.xz

if [ -f reaper.tar.xz ]; then
    # Extract and install
    tar -xf reaper.tar.xz
    cd reaper_linux_x86_64
    sudo ./install-reaper.sh --install /opt --integrate-desktop --usr-local-bin-symlink
    cd /tmp
    rm -rf reaper.tar.xz reaper_linux_x86_64
    echo "✅ REAPER installed successfully"
else
    echo "❌ Failed to download REAPER"
    exit 0
fi

exit 0

