#!/bin/bash

# Install Warp Terminal - Modern, AI-powered terminal
# https://www.warp.dev/

# Exit if already installed
if command -v warp-terminal &> /dev/null; then
    echo "✓ Warp Terminal already installed, skipping..."
    exit 0
fi

echo "Installing Warp Terminal..."

# Remove any existing conflicting repository configuration
sudo rm -f /etc/apt/sources.list.d/warp.list
sudo rm -f /usr/share/keyrings/warp.gpg

# Add Warp GPG key and repository
curl -fsSL https://releases.warp.dev/linux/keys/warp.asc | sudo gpg --dearmor -o /usr/share/keyrings/warp.gpg

# Create repository configuration with proper signed-by
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/warp.gpg] https://releases.warp.dev/linux/deb stable main" | sudo tee /etc/apt/sources.list.d/warp.list > /dev/null

# Update and install
sudo apt update -y
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

