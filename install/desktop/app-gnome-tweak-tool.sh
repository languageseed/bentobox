#!/bin/bash

if dpkg -s gnome-tweak-tool &> /dev/null || dpkg -s gnome-tweaks &> /dev/null; then
    echo "✓ GNOME Tweaks already installed, skipping..."
    exit 0
fi

sudo apt install -y gnome-tweaks
