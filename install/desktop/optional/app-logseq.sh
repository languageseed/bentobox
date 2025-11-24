#!/bin/bash

# Install Logseq - Knowledge management and collaboration platform
# https://logseq.com/

# Exit if already installed
if [ -f "/opt/Logseq/logseq" ] || command -v logseq &> /dev/null; then
    echo "✓ Logseq already installed, skipping..."
    exit 0
fi

echo "Installing Logseq..."

# Get latest version from GitHub
LOGSEQ_VERSION=$(curl -s https://api.github.com/repos/logseq/logseq/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")')

if [ -z "$LOGSEQ_VERSION" ]; then
    echo "❌ Failed to get Logseq version"
    exit 0
fi

# Download AppImage
cd /tmp
wget -q "https://github.com/logseq/logseq/releases/download/${LOGSEQ_VERSION}/Logseq-linux-x64-${LOGSEQ_VERSION}.AppImage" -O Logseq.AppImage

if [ -f Logseq.AppImage ]; then
    # Make it executable
    chmod +x Logseq.AppImage
    
    # Move to /opt
    sudo mkdir -p /opt/Logseq
    sudo mv Logseq.AppImage /opt/Logseq/logseq
    
    # Create desktop entry
    cat << EOF | sudo tee /usr/share/applications/logseq.desktop > /dev/null
[Desktop Entry]
Name=Logseq
Comment=A privacy-first, open-source knowledge base
Exec=/opt/Logseq/logseq %U
Terminal=false
Type=Application
Icon=logseq
Categories=Office;Productivity;
MimeType=x-scheme-handler/logseq;
StartupWMClass=Logseq
EOF
    
    # Download icon
    sudo wget -q "https://raw.githubusercontent.com/logseq/logseq/master/resources/icon.png" -O /usr/share/pixmaps/logseq.png 2>/dev/null || true
    
    echo "✅ Logseq installed successfully"
else
    echo "❌ Failed to download Logseq"
    exit 0
fi

exit 0

