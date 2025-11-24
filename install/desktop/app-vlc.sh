#!/bin/bash

if command -v vlc &> /dev/null; then
    echo "✓ VLC already installed, skipping..."
    exit 0
fi

sudo apt install -y vlc
