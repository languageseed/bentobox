#!/bin/bash

# Vertical Workspaces (V-Shell) Extension
# Metadata
# name: Vertical Workspaces
# category: gnome-extension
# description: Vertical workspace layout and customizable overview
# url: https://extensions.gnome.org/extension/5177/

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

echo "Installing Vertical Workspaces extension..."
gext install 5177 || {
    echo "⚠️  Automatic installation failed"
    echo "   Please install manually from: https://extensions.gnome.org/extension/5177/"
    exit 0
}

echo "✅ Vertical Workspaces installed!"
echo "   Enable it in the Extensions app or via: gnome-extensions enable vertical-workspaces@G-dH.github.com"

exit 0

