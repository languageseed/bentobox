#!/bin/bash

# Install Timeshift - System backup and restore tool
# https://github.com/linuxmint/timeshift

# Exit if already installed
if command -v timeshift &> /dev/null; then
    echo "✓ Timeshift already installed, skipping..."
    exit 0
fi

echo "Installing Timeshift..."

# Install from Ubuntu repositories
sudo apt update -y
sudo apt install -y timeshift

echo "✅ Timeshift installed successfully"
echo ""
echo "💡 To use Timeshift:"
echo "   1. Launch from Applications or run 'sudo timeshift-gtk'"
echo "   2. Select snapshot type (RSYNC recommended for most users)"
echo "   3. Configure backup location and schedule"
echo "   4. Create your first snapshot"
echo ""

exit 0

