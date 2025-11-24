#!/bin/bash

# Install Portmaster - Application firewall and privacy tool
# https://safing.io/

# Exit if already installed
if command -v portmaster &> /dev/null; then
    echo "✓ Portmaster already installed, skipping..."
    exit 0
fi

echo "Installing Portmaster..."

# Download and run installer script
cd /tmp
wget -q "https://updates.safing.io/latest/linux_amd64/packages/portmaster-installer.deb" -O portmaster-installer.deb

if [ -f portmaster-installer.deb ]; then
    sudo apt install -y ./portmaster-installer.deb
    rm portmaster-installer.deb
    
    echo "✅ Portmaster installed successfully"
    echo ""
    echo "💡 Portmaster features:"
    echo "   • Application-level firewall"
    echo "   • Block trackers and ads"
    echo "   • Monitor all network connections"
    echo "   • SPN (Safing Privacy Network) support"
    echo ""
    echo "   Launch from Applications or run: portmaster-start"
    echo "   Access UI: http://127.0.0.1:817/"
    echo ""
else
    echo "❌ Failed to download Portmaster"
    exit 0
fi

exit 0

