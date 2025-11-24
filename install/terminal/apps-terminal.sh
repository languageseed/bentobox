#!/bin/bash

# Check if terminal apps are already installed
APPS_TO_INSTALL=()
for app in fzf ripgrep bat eza zoxide plocate apache2-utils fd-find; do
    if ! dpkg -l | grep -q "^ii  $app "; then
        APPS_TO_INSTALL+=("$app")
    fi
done

if [ ${#APPS_TO_INSTALL[@]} -gt 0 ]; then
    sudo apt install -y "${APPS_TO_INSTALL[@]}"
else
    echo "✓ Terminal apps already installed"
fi
