#!/bin/bash

if command -v flameshot &> /dev/null; then
    echo "✓ Flameshot already installed, skipping..."
    exit 0
fi

# Flameshot is a nice step-up over the default Gnome screenshot tool
sudo apt install -y flameshot
