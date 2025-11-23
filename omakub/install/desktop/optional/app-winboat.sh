#!/bin/bash
# WinBoat Installation for Bentobox
# Run Windows applications seamlessly on Linux ("Reverse WSL")
# Status: BETA - Advanced Users Only

set -e

WINBOAT_VERSION="0.8.7"
WINBOAT_APPIMAGE_URL="https://github.com/TibixDev/winboat/releases/download/v${WINBOAT_VERSION}/winboat-${WINBOAT_VERSION}-x86_64.AppImage"

# Show beta warning
echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                    WinBoat (BETA)                            ║"
echo "║          Run Windows Apps Seamlessly on Linux                ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
echo "⚠️  BETA SOFTWARE - Advanced Users Only"
echo ""
echo "Requirements:"
echo "  • 8GB+ RAM (16GB recommended)"
echo "  • 50GB+ free disk space for Windows VM"
echo "  • CPU virtualization (VT-x/AMD-V) enabled in BIOS"
echo ""
echo "Best for:"
echo "  ✅ Adobe Suite (Photoshop, Illustrator, etc.)"
echo "  ✅ Microsoft Office 365"
echo "  ✅ Professional Windows-only applications"
echo ""
echo "NOT for:"
echo "  ❌ Gaming (use Proton/WINE instead)"
echo "  ❌ GPU-intensive tasks"
echo "  ❌ Apps that work fine in WINE"
echo ""
echo "Note: Installation requires ~800MB for prerequisites"
echo "      Windows VM download happens later (~5GB, 30-60 minutes)"
echo ""

read -p "Continue with WinBoat installation? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "WinBoat installation cancelled."
    exit 0
fi

echo ""
echo "Installing WinBoat prerequisites..."

# Install libfuse2 (required for AppImages)
sudo apt-get install -y libfuse2t64 || sudo apt-get install -y libfuse2

# Install FreeRDP 3.x (required for RDP connections)
sudo apt-get install -y freerdp3-x11

# Install virtualization stack
sudo apt-get install -y \
    qemu-kvm \
    libvirt-daemon-system \
    libvirt-clients \
    bridge-utils \
    virt-manager

# Install Docker if not present
if ! command -v docker &> /dev/null; then
    echo "Installing Docker..."
    sudo apt-get install -y docker.io docker-compose
    sudo systemctl enable --now docker
fi

# Enable and start libvirt
sudo systemctl enable libvirtd
sudo systemctl start libvirtd

# Add user to required groups
sudo usermod -aG docker,kvm,libvirt $USER

echo "Downloading WinBoat..."

# Create installation directory
mkdir -p ~/.local/bin

# Download WinBoat AppImage
wget -q --show-progress -O ~/.local/bin/winboat "$WINBOAT_APPIMAGE_URL"
chmod +x ~/.local/bin/winboat

# Create desktop entry
mkdir -p ~/.local/share/applications
cat > ~/.local/share/applications/winboat.desktop << 'EOF'
[Desktop Entry]
Name=WinBoat
Comment=Run Windows applications on Linux with seamless integration
Exec=env GDK_BACKEND=x11 /home/USER/.local/bin/winboat
Icon=application-x-executable
Terminal=false
Type=Application
Categories=System;Emulator;Virtualization;
Keywords=windows;vm;virtual machine;emulator;
StartupNotify=true
EOF

# Replace USER placeholder
sed -i "s|/home/USER|$HOME|g" ~/.local/share/applications/winboat.desktop

# Update desktop database
update-desktop-database ~/.local/share/applications/ 2>/dev/null || true

echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║          WinBoat Installation Complete! 🎉                   ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
echo "⚠️  IMPORTANT: LOGOUT AND LOGIN REQUIRED"
echo ""
echo "Before using WinBoat, you MUST logout and login again"
echo "for group permissions to take effect."
echo ""
echo "After logging back in:"
echo ""
echo "🚀 Launch WinBoat:"
echo "   • Applications menu → Search 'WinBoat'"
echo "   • Or run: winboat"
echo ""
echo "📋 First-time setup:"
echo "   1. WinBoat will show a setup wizard"
echo "   2. Choose Windows 10 (recommended, more stable)"
echo "   3. Allocate resources: 4-8GB RAM, 2-4 CPU cores"
echo "   4. Wait 30-60 minutes for Windows installation"
echo "   5. Guest service installs automatically"
echo "   6. Start using Windows apps!"
echo ""
echo "💡 Tips:"
echo "   • Your Linux home directory is accessible from Windows"
echo "   • Windows apps appear as native Linux windows"
echo "   • Clipboard works between Linux and Windows"
echo ""
echo "📚 Resources:"
echo "   • Documentation: https://www.winboat.app/"
echo "   • GitHub: https://github.com/TibixDev/winboat"
echo ""
echo "⚠️  Remember to LOGOUT and LOGIN before first use!"
echo ""

