#!/bin/bash

# Install Draw.io (diagrams.net) - Diagramming and whiteboarding tool
# https://www.drawio.com/

# Exit if already installed
if command -v drawio &> /dev/null; then
    echo "✓ Draw.io already installed, skipping..."
    exit 0
fi

echo "Installing Draw.io..."

# Download latest release from GitHub
DRAWIO_VERSION=$(curl -s https://api.github.com/repos/jgraph/drawio-desktop/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")')

if [ -z "$DRAWIO_VERSION" ]; then
    echo "❌ Failed to get Draw.io version"
    exit 0
fi

# Remove 'v' prefix if present
DRAWIO_VERSION=${DRAWIO_VERSION#v}

# Download and install .deb package
cd /tmp
wget -q "https://github.com/jgraph/drawio-desktop/releases/download/v${DRAWIO_VERSION}/drawio-amd64-${DRAWIO_VERSION}.deb" -O drawio.deb

if [ -f drawio.deb ]; then
    sudo apt install -y ./drawio.deb
    rm drawio.deb
    echo "✅ Draw.io installed successfully"
else
    echo "❌ Failed to download Draw.io"
    exit 0
fi

exit 0

