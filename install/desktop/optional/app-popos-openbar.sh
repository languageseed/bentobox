#!/bin/bash

# Open Bar Extension
# Metadata
# name: Open Bar
# category: gnome-extension
# description: Customizable top panel with widgets
# url: https://extensions.gnome.org/extension/6580/

set -e

# Check if gext is available
if ! command -v gext &> /dev/null; then
    echo "Installing GNOME Extension CLI..."
    sudo apt update
    sudo apt install -y python3-pip python3-venv
    pip3 install --user pipx
    export PATH="$HOME/.local/bin:$PATH"
    pipx install gnome-extensions-cli
fi

echo "Installing Open Bar extension..."
gext install 6580 || {
    echo "⚠️  Automatic installation failed"
    echo "   Please install manually from: https://extensions.gnome.org/extension/6580/"
    exit 0
}

echo "✅ Open Bar installed!"
echo "   Enable it in the Extensions app or via: gnome-extensions enable openbar@2tofixed.com"

exit 0

