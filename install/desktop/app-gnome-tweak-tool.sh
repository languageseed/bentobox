#!/bin/bash

# Check if GNOME Tweaks is already installed
TWEAKS_INSTALLED=false
if dpkg -s gnome-tweak-tool &> /dev/null || dpkg -s gnome-tweaks &> /dev/null; then
    TWEAKS_INSTALLED=true
fi

# Check if Extension Manager is already installed
EXT_MGR_INSTALLED=false
if dpkg -s gnome-shell-extension-manager &> /dev/null; then
    EXT_MGR_INSTALLED=true
fi

# Skip if both are already installed
if [ "$TWEAKS_INSTALLED" = true ] && [ "$EXT_MGR_INSTALLED" = true ]; then
    echo "✓ GNOME Tweaks and Extension Manager already installed, skipping..."
    exit 0
fi

# Install what's missing
PACKAGES=()

if [ "$TWEAKS_INSTALLED" = false ]; then
    PACKAGES+=("gnome-tweaks")
fi

if [ "$EXT_MGR_INSTALLED" = false ]; then
    PACKAGES+=("gnome-shell-extension-manager")
fi

if [ ${#PACKAGES[@]} -gt 0 ]; then
    echo "Installing: ${PACKAGES[*]}"
    sudo apt install -y "${PACKAGES[@]}"
fi
