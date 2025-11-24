#!/bin/bash

# Dash2Dock Lite Extension
# Metadata
# name: Dash2Dock Lite
# category: gnome-extension
# description: Animated dock with lightweight effects
# url: https://extensions.gnome.org/extension/4994/

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

echo "Installing Dash2Dock Lite extension..."
gext install 4994 || {
    echo "⚠️  Automatic installation failed"
    echo "   Please install manually from: https://extensions.gnome.org/extension/4994/"
    exit 0
}

echo "✅ Dash2Dock Lite installed!"
echo "   Enable it in the Extensions app or via: gnome-extensions enable dash2dock@icedman.github.com"

exit 0

