#!/bin/bash

# Install Blender - 3D creation suite
# https://www.blender.org/

# Exit if already installed
if command -v blender &> /dev/null; then
    echo "✓ Blender already installed, skipping..."
    exit 0
fi

echo "Installing Blender..."

# Install via snap (most up-to-date version)
sudo snap install blender --classic

echo "✅ Blender installed successfully"

exit 0

