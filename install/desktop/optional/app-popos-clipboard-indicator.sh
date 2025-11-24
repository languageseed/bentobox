#!/bin/bash

# Clipboard Indicator Extension
# Metadata
# name: Clipboard Indicator
# category: gnome-extension
# description: Clipboard history manager for GNOME
# url: https://extensions.gnome.org/extension/779/

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

echo "Installing Clipboard Indicator extension..."
gext install 779 || {
    echo "⚠️  Automatic installation failed"
    echo "   Please install manually from: https://extensions.gnome.org/extension/779/"
    exit 0
}

echo "✅ Clipboard Indicator installed!"
echo "   Enable it in the Extensions app or via: gnome-extensions enable clipboard-indicator@tudmotu.com"

exit 0

