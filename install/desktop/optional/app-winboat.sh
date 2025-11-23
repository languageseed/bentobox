#!/bin/bash
# WinBoat - Run Windows Apps on Linux ("Reverse WSL")
# BETA software - Advanced users only

echo "Installing WinBoat (Run Windows apps on Linux)..."

# Install prerequisites
sudo apt-get update -qq
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y \
    docker.io \
    docker-compose \
    qemu-kvm \
    libvirt-daemon-system \
    libvirt-clients \
    bridge-utils \
    virt-manager \
    qemu-system-x86 \
    libfuse2 \
    freerdp3-x11 >/dev/null 2>&1

# Enable services
sudo systemctl enable --now docker
sudo systemctl enable --now libvirtd
sudo systemctl start virtlogd 2>/dev/null || true

# Add user to required groups
sudo usermod -aG docker ${USER}
sudo usermod -aG kvm ${USER}
sudo usermod -aG libvirt ${USER}

# Download WinBoat AppImage
mkdir -p ~/.local/bin
WINBOAT_VERSION="v0.8.7"
wget -q --show-progress -O ~/.local/bin/winboat \
    "https://github.com/TibixDev/winboat/releases/download/${WINBOAT_VERSION}/winboat-${WINBOAT_VERSION#v}-x86_64.AppImage"
chmod +x ~/.local/bin/winboat

# Ensure ~/.local/bin in PATH
if ! echo "$PATH" | grep -q "$HOME/.local/bin"; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
fi

# Create desktop entry
mkdir -p ~/.local/share/applications
cat > ~/.local/share/applications/winboat.desktop << EOF
[Desktop Entry]
Name=WinBoat
Comment=Run Windows applications on Linux with seamless integration
Exec=$HOME/.local/bin/winboat --no-sandbox
Icon=winboat
Terminal=false
Type=Application
Categories=System;Emulator;Virtualization;
Keywords=windows;vm;virtual machine;emulator;
StartupNotify=true
EOF

echo "✅ WinBoat installed"
echo ""
echo "⚠️  IMPORTANT: WinBoat requires LOGOUT/REBOOT to activate group permissions"
echo "   After rebooting:"
echo "   1. Launch WinBoat from applications menu"
echo "   2. Follow Windows installation wizard (recommend Windows 10)"
echo "   3. Wait 30-60 minutes for Windows to install"
echo ""
echo "   For help: https://www.winboat.app/"

