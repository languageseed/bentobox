#!/bin/bash

# Pop!_OS Pop Shell - Tiling window manager
# Metadata
# name: Pop Shell
# category: desktop-extension
# description: Advanced automatic tiling window manager by System76
# url: https://github.com/pop-os/shell

set -e

# Check if already installed
if dpkg -l | grep -q pop-shell; then
    echo "✓ Pop Shell already installed, skipping..."
    exit 0
fi

echo "Installing Pop Shell..."
sudo apt update
sudo apt install -y pop-shell

echo "✅ Pop Shell installed successfully!"
echo "   Log out and log back in to activate"

exit 0

