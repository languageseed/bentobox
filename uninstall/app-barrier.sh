#!/bin/bash

# Uninstall Barrier

echo "Uninstalling Barrier..."

sudo apt remove -y barrier
sudo apt autoremove -y

# Remove any leftover config files
rm -rf ~/.local/share/barrier
rm -rf ~/.config/barrier

echo "✅ Barrier uninstalled!"



