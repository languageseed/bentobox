#!/bin/bash

# Uninstall Tailscale

echo "Stopping Tailscale..."
sudo tailscale down 2>/dev/null || true

echo "Uninstalling Tailscale..."
sudo apt remove -y tailscale
sudo apt autoremove -y

# Remove configuration files
sudo rm -rf /var/lib/tailscale
sudo rm -rf /etc/tailscale

echo "✅ Tailscale uninstalled!"
echo ""
echo "Note: Your device has been removed from your Tailscale network."
echo "You can also remove it from the web dashboard at:"
echo "https://login.tailscale.com/admin"
