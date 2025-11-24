#!/bin/bash

if command -v wl-copy &> /dev/null; then
    echo "✓ wl-clipboard already installed, skipping..."
    exit 0
fi

# Provides a system clipboard interface for Neovim under Wayland
sudo apt install -y wl-clipboard
