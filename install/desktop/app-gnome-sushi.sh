#!/bin/bash

if dpkg -s gnome-sushi &> /dev/null; then
    echo "✓ GNOME Sushi already installed, skipping..."
    exit 0
fi

# Gives you previews in the file manager when pressing space
sudo apt install -y gnome-sushi
