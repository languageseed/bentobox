#!/bin/bash
# Sublime Text installation for Bentobox
# Official stable channel from Sublime HQ

set -e

echo ""
echo "Installing Sublime Text..."
echo ""

# Install the GPG key
wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/sublimehq-archive.gpg > /dev/null

# Add the stable repository
echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list

# Update package list and install
sudo apt-get update
sudo apt-get install -y sublime-text

# Install Package Control automatically
PACKAGE_CONTROL_DIR="$HOME/.config/sublime-text/Installed Packages"
mkdir -p "$PACKAGE_CONTROL_DIR"

# Download Package Control
wget -q https://packagecontrol.io/Package%20Control.sublime-package -O "$PACKAGE_CONTROL_DIR/Package Control.sublime-package"

echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║          Sublime Text Installed Successfully! 🎉             ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
echo "Launch Sublime Text:"
echo "  • From applications menu: Search 'Sublime Text'"
echo "  • From terminal: subl"
echo ""
echo "Features:"
echo "  ✅ Package Control pre-installed"
echo "  ✅ Command line tool: 'subl'"
echo "  ✅ Multi-cursor editing"
echo "  ✅ Goto Anything (Ctrl+P)"
echo "  ✅ Command Palette (Ctrl+Shift+P)"
echo ""
echo "Install packages:"
echo "  1. Press Ctrl+Shift+P"
echo "  2. Type: Package Control: Install Package"
echo "  3. Search and install packages"
echo ""
echo "Popular packages to try:"
echo "  • LSP (Language Server Protocol support)"
echo "  • Emmet (HTML/CSS shortcuts)"
echo "  • GitGutter (Git diff in gutter)"
echo "  • SideBarEnhancements (Better sidebar)"
echo "  • Terminus (Better terminal)"
echo ""
echo "Documentation: https://www.sublimetext.com/docs/"
echo ""

