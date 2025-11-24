#!/bin/bash

# Install Warp Terminal - Modern, AI-powered terminal
# https://www.warp.dev/

# Exit if already installed
if command -v warp-terminal &> /dev/null; then
    echo "✓ Warp Terminal already installed, skipping..."
    exit 0
fi

echo "Installing Warp Terminal..."

# Remove any existing conflicting repository configuration (both old and new style)
sudo rm -f /etc/apt/sources.list.d/warp.list
sudo rm -f /etc/apt/sources.list.d/warpdotdev.list
sudo rm -f /usr/share/keyrings/warp.gpg
sudo rm -f /etc/apt/trusted.gpg.d/warpdotdev.gpg

echo "✓ Cleaned up any existing Warp repository configuration"

# Add Warp GPG key and repository
curl -fsSL https://releases.warp.dev/linux/keys/warp.asc | sudo gpg --dearmor -o /usr/share/keyrings/warp.gpg

# Create repository configuration with proper signed-by
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/warp.gpg] https://releases.warp.dev/linux/deb stable main" | sudo tee /etc/apt/sources.list.d/warp.list > /dev/null

echo "✓ Added Warp repository with new GPG key"

# Update and install (filter out harmless warnings)
sudo apt update 2>&1 | grep -v "Conflicting values set for option Signed-By" || true
sudo apt install -y warp-terminal

echo "✅ Warp Terminal installed successfully"
echo ""
echo "💡 Warp features:"
echo "   • AI-powered command suggestions"
echo "   • Built-in knowledge base"
echo "   • Modern UI with IDE-like features"
echo "   • Block-based output"
echo ""
echo "   Launch from Applications or run: warp-terminal"
echo ""

exit 0

