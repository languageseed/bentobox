#!/bin/bash

# Uninstall Synergy

echo "Uninstalling Synergy..."

flatpak uninstall -y com.symless.Synergy

# Remove any leftover config files
rm -rf ~/.local/share/synergy
rm -rf ~/.config/synergy

echo "✅ Synergy uninstalled!"



