#!/bin/bash
# Download Windows 10 ISO for WinBoat
# Windows 10 22H2 is recommended (more stable than Windows 11 in VMs)

echo "Downloading Windows 10 ISO for WinBoat..."
echo ""
echo "ℹ️  This will download ~5.8GB to ~/Downloads"
echo "   WinBoat can use this ISO instead of auto-downloading"
echo ""

# Create Downloads directory
mkdir -p ~/Downloads
cd ~/Downloads

# Download Windows 10 22H2 ISO (official Microsoft download)
# Note: This is the direct ISO link from Microsoft
ISO_FILE="Win10_22H2_English_x64.iso"
ISO_URL="https://software-static.download.prss.microsoft.com/dbazure/988969d5-f34g-4e03-ac9d-1f9786c66749/Win10_22H2_English_x64v1.iso"

echo "Downloading Windows 10 22H2 (Build 19045)..."
echo "  Source: Microsoft Official"
echo "  Size: ~5.8 GB"
echo "  Target: ~/Downloads/$ISO_FILE"
echo ""

if command -v wget &> /dev/null; then
    wget -c --show-progress -O "$ISO_FILE" "$ISO_URL"
elif command -v curl &> /dev/null; then
    curl -L -C - --progress-bar -o "$ISO_FILE" "$ISO_URL"
else
    echo "❌ Neither wget nor curl found!"
    echo ""
    echo "Manual download:"
    echo "  1. Visit: https://www.microsoft.com/software-download/windows10ISO"
    echo "  2. Select: Windows 10 (multi-edition ISO)"
    echo "  3. Choose: English (United States)"
    echo "  4. Save to: ~/Downloads/"
    exit 1
fi

# Verify download
if [ -f "$ISO_FILE" ]; then
    FILE_SIZE=$(du -h "$ISO_FILE" | cut -f1)
    echo ""
    echo "✅ Windows 10 ISO downloaded successfully!"
    echo "   Location: ~/Downloads/$ISO_FILE"
    echo "   Size: $FILE_SIZE"
    echo ""
    echo "📝 Next steps:"
    echo "   1. Install WinBoat (if not already installed)"
    echo "   2. Launch WinBoat from Applications menu"
    echo "   3. In WinBoat setup, point to this ISO"
    echo "   4. Skip WinBoat's automatic download step"
    echo ""
else
    echo "❌ Download failed!"
    echo ""
    echo "Manual download:"
    echo "  Visit: https://www.microsoft.com/software-download/windows10ISO"
    exit 1
fi

