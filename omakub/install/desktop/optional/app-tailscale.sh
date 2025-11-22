#!/bin/bash

# Tailscale - Zero-config VPN for secure remote access
# Connect devices across the internet as if they were on the same local network
# https://tailscale.com

echo "Installing Tailscale..."

# Install using official Tailscale script
curl -fsSL https://tailscale.com/install.sh | sh

echo ""
echo "✅ Tailscale installed!"
echo ""
echo "Next steps:"
echo "  1. Start Tailscale: sudo tailscale up"
echo "  2. Authenticate in browser when prompted"
echo "  3. Your device is now on your Tailscale network"
echo ""
echo "Useful commands:"
echo "  - tailscale status    # Check connection status"
echo "  - tailscale ip        # Show your Tailscale IP"
echo "  - tailscale ping      # Ping other devices"
echo "  - tailscale down      # Disconnect"
echo ""
echo "Web dashboard: https://login.tailscale.com/admin"



