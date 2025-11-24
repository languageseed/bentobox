#!/bin/bash

# Coverflow Alt-Tab Extension
# Metadata
# name: Coverflow Alt-Tab
# category: gnome-extension
# description: Enhanced Alt+Tab with cover flow animation
# url: https://extensions.gnome.org/extension/97/

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

echo "Installing Coverflow Alt-Tab extension..."
gext install 97 || {
    echo "⚠️  Automatic installation failed"
    echo "   Please install manually from: https://extensions.gnome.org/extension/97/"
    exit 0
}

echo "✅ Coverflow Alt-Tab installed!"
echo "   Enable it in the Extensions app or via: gnome-extensions enable CoverflowAltTab@palatis.blogspot.com"

exit 0

