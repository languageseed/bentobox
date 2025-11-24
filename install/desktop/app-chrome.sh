#!/bin/bash

# Check if Chrome should be skipped (already installed)
if [ "$SKIP_CHROME" = "true" ]; then
    echo "✓ Chrome already installed, skipping..."
    exit 0
fi

# Browse the web with the most popular browser. See https://www.google.com/chrome/
cd /tmp
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt install -y ./google-chrome-stable_current_amd64.deb
rm google-chrome-stable_current_amd64.deb
xdg-settings set default-web-browser google-chrome.desktop
cd -
