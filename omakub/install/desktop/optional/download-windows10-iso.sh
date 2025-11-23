#!/bin/bash
# Windows 10 ISO Download for WinBoat/VM usage
# Downloads official Windows 10 22H2 ISO from Microsoft

set -e

echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║              Windows 10 ISO Download                         ║"
echo "║          For use with WinBoat or VMs                         ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
echo "This will download Windows 10 22H2 (English International)"
echo ""
echo "Details:"
echo "  • Size: ~5.8 GB"
echo "  • Time: 10-20 minutes (depending on connection)"
echo "  • Location: ~/Downloads/Win10_22H2_x64.iso"
echo ""
echo "Benefits of pre-downloading:"
echo "  ✅ Faster WinBoat setup (no download wait)"
echo "  ✅ Reusable for multiple VMs"
echo "  ✅ Keep for offline installation"
echo ""
echo "⚠️  Note: This download happens in the background"
echo "    You can continue using your computer"
echo ""

read -p "Continue with Windows 10 ISO download? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Windows 10 ISO download cancelled."
    exit 0
fi

echo ""
echo "Starting Windows 10 ISO download..."
echo ""

# Create Downloads directory if it doesn't exist
mkdir -p ~/Downloads
cd ~/Downloads

# Check if already downloaded
if [ -f "Win10_22H2_x64.iso" ]; then
    echo "✅ Windows 10 ISO already exists!"
    echo ""
    ls -lh Win10_22H2_x64.iso
    echo ""
    read -p "Re-download anyway? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Using existing ISO file."
        exit 0
    fi
    rm -f Win10_22H2_x64.iso
fi

# Microsoft's direct download link
# Note: This link has a time-limited token and may expire
# If it fails, the script provides instructions for manual download
WIN10_URL="https://software.download.prss.microsoft.com/dbazure/Win10_22H2_EnglishInternational_x64v1.iso"

echo "Downloading from Microsoft servers..."
echo "This may take 10-20 minutes depending on your internet speed."
echo ""

# Try to download with progress bar
if wget --show-progress -O Win10_22H2_x64.iso "$WIN10_URL" 2>&1; then
    echo ""
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║          Windows 10 ISO Downloaded Successfully! 🎉          ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo ""
    echo "Location: ~/Downloads/Win10_22H2_x64.iso"
    echo ""
    ls -lh ~/Downloads/Win10_22H2_x64.iso
    echo ""
    echo "To use with WinBoat:"
    echo "  1. Launch WinBoat"
    echo "  2. During setup, look for 'Use custom ISO' or 'Browse'"
    echo "  3. Select: ~/Downloads/Win10_22H2_x64.iso"
    echo "  4. This skips the automatic download!"
    echo ""
    echo "To use with other VMs:"
    echo "  • VirtualBox: Use as installation media"
    echo "  • virt-manager: Create new VM and select this ISO"
    echo "  • QEMU: -cdrom ~/Downloads/Win10_22H2_x64.iso"
    echo ""
else
    echo ""
    echo "❌ Download failed!"
    echo ""
    echo "The direct download link may have expired."
    echo ""
    echo "Manual download instructions:"
    echo ""
    echo "1. Visit: https://www.microsoft.com/software-download/windows10ISO"
    echo ""
    echo "2. Select:"
    echo "   • Edition: Windows 10 (multi-edition ISO)"
    echo "   • Language: English (International) or your preference"
    echo "   • Architecture: 64-bit"
    echo ""
    echo "3. Download the ISO to ~/Downloads/"
    echo ""
    echo "4. Rename to: Win10_22H2_x64.iso"
    echo ""
    echo "The official Microsoft download page will generate a fresh link."
    echo ""
    exit 1
fi

