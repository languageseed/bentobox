#!/bin/bash

# User Themes Extension (required for custom shell themes)
# Metadata
# name: User Themes Extension
# category: desktop-extension
# description: Allows loading shell themes from user's home directory
# url: https://extensions.gnome.org/extension/19/user-themes/

set -e

# Check if already enabled
if gnome-extensions list 2>/dev/null | grep -q "user-theme@gnome-shell-extensions.gcampax.github.com"; then
    echo "✓ User Themes extension already installed, skipping..."
    exit 0
fi

echo "Installing User Themes extension..."

# Install from package (most reliable)
sudo apt install -y gnome-shell-extensions

# Enable the extension
gnome-extensions enable user-theme@gnome-shell-extensions.gcampax.github.com 2>/dev/null || true

echo "✅ User Themes extension installed!"
echo "   ⚠️  You may need to logout/login for it to take effect"
echo "   This extension allows custom shell themes in GNOME Tweaks"

exit 0

