#!/bin/bash
# Bentobox Uninstall Script
# Removes Bentobox and resets Ubuntu to near-default state

set +e  # Continue on errors

echo "🗑️  Bentobox Uninstall & Reset"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Counter
REMOVED=0

echo "📦 Stopping and removing Docker containers..."
# Stop containers
docker stop portainer open-webui ollama 2>/dev/null && echo "  ✓ Containers stopped" || echo "  ⚠ Some containers not found"
# Remove containers
docker rm portainer open-webui ollama 2>/dev/null && echo "  ✓ Containers removed"
# Remove volumes (optional - commented out to preserve data)
# docker volume rm portainer_data open-webui ollama 2>/dev/null

echo ""
echo "🎨 Resetting GNOME theme and settings..."
# Reset theme
gsettings reset org.gnome.desktop.interface gtk-theme 2>/dev/null && echo "  ✓ GTK theme reset"
gsettings reset org.gnome.desktop.interface icon-theme 2>/dev/null && echo "  ✓ Icon theme reset"
gsettings reset org.gnome.desktop.interface color-scheme 2>/dev/null && echo "  ✓ Color scheme reset"

# Reset wallpaper
gsettings reset org.gnome.desktop.background picture-uri 2>/dev/null && echo "  ✓ Wallpaper reset"
gsettings reset org.gnome.desktop.background picture-uri-dark 2>/dev/null

# Reset fonts
gsettings reset org.gnome.desktop.interface monospace-font-name 2>/dev/null && echo "  ✓ Font settings reset"
gsettings reset org.gnome.desktop.interface font-name 2>/dev/null

# Reset GNOME Terminal profile (get default profile)
PROFILE=$(gsettings get org.gnome.Terminal.ProfilesList default 2>/dev/null | tr -d "'")
if [ -n "$PROFILE" ]; then
    gsettings reset org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$PROFILE/ font 2>/dev/null
    gsettings reset org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$PROFILE/ use-system-font 2>/dev/null
    echo "  ✓ Terminal font reset"
fi

echo ""
echo "📝 Removing custom fonts..."
# Remove Bentobox fonts (but keep directory for other fonts)
rm -f ~/.local/share/fonts/CaskaydiaMono*.ttf 2>/dev/null && echo "  ✓ Cascadia Mono removed" || echo "  ⚠ Cascadia Mono not found"
rm -f ~/.local/share/fonts/iAWriterMono*.ttf 2>/dev/null && echo "  ✓ iA Writer Mono removed" || echo "  ⚠ iA Writer Mono not found"
fc-cache -f 2>/dev/null && echo "  ✓ Font cache updated"

echo ""
echo "⚙️  Removing terminal configurations..."
# Reset bash config (preserve original but remove Bentobox additions)
if [ -f ~/.bashrc ]; then
    # Remove Bentobox lines (look for omakub references)
    sed -i.backup '/omakub/d' ~/.bashrc 2>/dev/null && echo "  ✓ Bashrc cleaned"
fi

# Remove Alacritty config if it was installed by Bentobox
if [ -f ~/.config/alacritty/alacritty.toml ]; then
    echo "  ℹ Alacritty config found (not removed - may be custom)"
fi

# Remove Zellij config
rm -rf ~/.config/zellij 2>/dev/null && echo "  ✓ Zellij config removed"

echo ""
echo "🔧 Removing development tools..."
# Note: We don't uninstall system packages to avoid breaking dependencies
# Users can manually run: sudo apt autoremove

# Remove mise (version manager)
if command -v mise &> /dev/null; then
    rm -rf ~/.local/share/mise 2>/dev/null
    rm -rf ~/.cache/mise 2>/dev/null
    echo "  ✓ mise removed"
fi

# Remove Node.js global packages installed via mise
rm -rf ~/.local/share/mise/installs/node 2>/dev/null

echo ""
echo "📦 Removing installed applications..."

# Read state file to see what was installed
STATE_FILE="$HOME/.bentobox-state.json"
if [ -f "$STATE_FILE" ]; then
    echo "  Using state file to determine what to remove..."
fi

# Desktop Applications
if command -v cursor &> /dev/null; then
    sudo apt remove -y cursor 2>/dev/null && echo "  ✓ Cursor removed" || echo "  ⚠ Cursor removal failed"
fi

if command -v code &> /dev/null; then
    sudo apt remove -y code 2>/dev/null && echo "  ✓ VS Code removed" || echo "  ⚠ VS Code removal failed"
fi

if command -v google-chrome &> /dev/null; then
    sudo apt remove -y google-chrome-stable 2>/dev/null && echo "  ✓ Chrome removed" || echo "  ⚠ Chrome removal failed"
fi

if command -v brave-browser &> /dev/null; then
    sudo apt remove -y brave-browser 2>/dev/null && echo "  ✓ Brave removed" || echo "  ⚠ Brave removal failed"
fi

if command -v typora &> /dev/null; then
    sudo apt remove -y typora 2>/dev/null && echo "  ✓ Typora removed" || echo "  ⚠ Typora removal failed"
fi

if command -v alacritty &> /dev/null; then
    sudo apt remove -y alacritty 2>/dev/null && echo "  ✓ Alacritty removed" || echo "  ⚠ Alacritty removal failed"
fi

# Flatpak apps
if command -v flatpak &> /dev/null; then
    flatpak list --app | grep -q "Pinta" && flatpak uninstall -y com.github.PintaProject.Pinta 2>/dev/null && echo "  ✓ Pinta removed"
    flatpak list --app | grep -q "GIMP" && flatpak uninstall -y org.gimp.GIMP 2>/dev/null && echo "  ✓ GIMP removed"
fi

# Terminal apps
if command -v btop &> /dev/null; then
    sudo apt remove -y btop 2>/dev/null && echo "  ✓ btop removed"
fi

if command -v fastfetch &> /dev/null; then
    sudo apt remove -y fastfetch 2>/dev/null && echo "  ✓ fastfetch removed"
fi

if command -v lazygit &> /dev/null; then
    # lazygit is usually installed to /usr/local/bin
    sudo rm -f /usr/local/bin/lazygit 2>/dev/null && echo "  ✓ lazygit removed"
fi

if command -v zellij &> /dev/null; then
    sudo rm -f /usr/local/bin/zellij 2>/dev/null && echo "  ✓ zellij removed"
fi

if command -v gh &> /dev/null; then
    sudo apt remove -y gh 2>/dev/null && echo "  ✓ GitHub CLI removed"
fi

# Docker (optional - only if no other containers are running)
if command -v docker &> /dev/null; then
    CONTAINER_COUNT=$(docker ps -a -q | wc -l)
    if [ "$CONTAINER_COUNT" -eq 0 ]; then
        if [ "$1" = "--remove-docker" ]; then
            sudo apt remove -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin 2>/dev/null && echo "  ✓ Docker removed"
        else
            echo "  ℹ Docker kept (use --remove-docker to remove)"
        fi
    else
        echo "  ℹ Docker kept (other containers exist)"
    fi
fi

# Other applications
if dpkg -l | grep -q vlc; then
    sudo apt remove -y vlc 2>/dev/null && echo "  ✓ VLC removed"
fi

if dpkg -l | grep -q libreoffice; then
    sudo apt remove -y libreoffice-core 2>/dev/null && echo "  ✓ LibreOffice removed"
fi

if dpkg -l | grep -q flameshot; then
    sudo apt remove -y flameshot 2>/dev/null && echo "  ✓ Flameshot removed"
fi

if dpkg -l | grep -q gnome-tweaks; then
    sudo apt remove -y gnome-tweaks 2>/dev/null && echo "  ✓ GNOME Tweaks removed"
fi

if dpkg -l | grep -q ulauncher; then
    sudo apt remove -y ulauncher 2>/dev/null && echo "  ✓ Ulauncher removed"
fi

# Virtualization tools
if command -v virt-manager &> /dev/null; then
    if [ "$1" = "--remove-virt" ]; then
        sudo apt remove -y virt-manager qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils 2>/dev/null && echo "  ✓ Virtualization tools removed"
    else
        echo "  ℹ Virtualization tools kept (use --remove-virt to remove)"
    fi
fi

# WinBoat VMs (remove VM images)
if [ -d "$HOME/.local/share/libvirt/images" ]; then
    WINBOAT_VMS=$(ls "$HOME/.local/share/libvirt/images" | grep -i windows 2>/dev/null)
    if [ -n "$WINBOAT_VMS" ]; then
        if [ "$1" = "--remove-vms" ] || [ "$1" = "--full" ]; then
            rm -rf "$HOME/.local/share/libvirt/images/"*windows* 2>/dev/null && echo "  ✓ Windows VM images removed"
        else
            echo "  ℹ Windows VM images kept (use --remove-vms to remove)"
        fi
    fi
fi

# ASDControl udev rules
if [ -f "/etc/udev/rules.d/99-ddcci.rules" ]; then
    sudo rm -f /etc/udev/rules.d/99-ddcci.rules 2>/dev/null && echo "  ✓ ASDControl rules removed"
    sudo udevadm control --reload-rules 2>/dev/null
fi

# Clean up PPAs and repositories
echo ""
echo "🗂️  Cleaning up repositories..."
sudo rm -f /etc/apt/sources.list.d/typora.list 2>/dev/null && echo "  ✓ Typora repo removed"
sudo rm -f /etc/apt/sources.list.d/github-cli.list 2>/dev/null && echo "  ✓ GitHub CLI repo removed"
sudo rm -f /etc/apt/sources.list.d/google-chrome.list 2>/dev/null && echo "  ✓ Chrome repo removed"
sudo rm -f /etc/apt/sources.list.d/vscode.list 2>/dev/null && echo "  ✓ VS Code repo removed"
sudo rm -f /etc/apt/sources.list.d/brave*.list 2>/dev/null && echo "  ✓ Brave repo removed"

# Remove GPG keys
sudo rm -f /etc/apt/keyrings/typora.gpg 2>/dev/null
sudo rm -f /usr/share/keyrings/githubcli-archive-keyring.gpg 2>/dev/null
sudo rm -f /etc/apt/keyrings/mise-archive-keyring.gpg 2>/dev/null

echo "  ✓ Repository cleanup complete"

echo ""
echo "🖼️  Removing wallpapers..."
rm -rf ~/.local/share/backgrounds/tokyo-night* 2>/dev/null && echo "  ✓ Custom wallpapers removed"

echo ""
echo "🗑️  Removing Bentobox files..."
# Remove state and config
rm -f ~/.bentobox-state.json 2>/dev/null && echo "  ✓ State file removed"
rm -f ~/.bentobox-config.yaml 2>/dev/null && echo "  ✓ Config file removed"

# Option to remove entire Bentobox installation
if [ "$1" = "--full" ]; then
    echo "  Removing Bentobox installation directory..."
    rm -rf ~/.local/share/omakub 2>/dev/null && echo "  ✓ Installation directory removed"
else
    echo "  ℹ Installation directory kept (run with --full to remove)"
    echo "    Location: ~/.local/share/omakub"
fi

# Remove GUI launcher
sudo rm -f /usr/local/bin/bentobox-gui 2>/dev/null && echo "  ✓ GUI launcher removed"
sudo rm -f /usr/share/applications/bentobox-installer.desktop 2>/dev/null && echo "  ✓ Desktop entry removed"
sudo update-desktop-database 2>/dev/null

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Uninstall Complete"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Your system has been reset to near-default Ubuntu state."
echo ""
echo "📝 What was removed:"
echo "  • Docker containers (Portainer, OpenWebUI, Ollama)"
echo "  • Desktop apps (Cursor, VS Code, Chrome, Alacritty, etc.)"
echo "  • Terminal tools (btop, fastfetch, lazygit, zellij, etc.)"
echo "  • GNOME customizations (theme, fonts, extensions)"
echo "  • Custom configurations and state files"
echo "  • Repository sources and GPG keys"
echo ""
echo "📝 Optional cleanup (run with flags):"
echo "  • --remove-docker     Remove Docker completely"
echo "  • --remove-virt       Remove virtualization tools"
echo "  • --remove-vms        Remove Windows VM images"
echo "  • --full              Remove everything including install dir"
echo ""
echo "📝 Next steps (optional):"
echo "  • Reboot your system: sudo reboot"
echo "  • Remove unused packages: sudo apt autoremove"
echo "  • Remove Bentobox dir: rm -rf ~/.local/share/omakub"
echo ""

