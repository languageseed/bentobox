#!/bin/bash
# WinBoat Installation Script for Bentobox
# Status: TESTED on Ubuntu 24.04.3 LTS
# Based on: Testing session November 23, 2024 on leaf system
# Version: 2.0 - Updated with real-world testing findings

set -e

# Configuration
WINBOAT_VERSION="v0.8.7"
WINBOAT_APPIMAGE_URL="https://github.com/TibixDev/winboat/releases/download/${WINBOAT_VERSION}/winboat-${WINBOAT_VERSION#v}-x86_64.AppImage"
WINBOAT_WEBSITE="https://www.winboat.app/"
WINBOAT_GITHUB="https://github.com/TibixDev/winboat"
MIN_RAM_GB=8
MIN_DISK_GB=50

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
success() { echo -e "${GREEN}✅ $1${NC}"; }
warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
error() { echo -e "${RED}❌ $1${NC}"; }

# Banner
cat << 'EOF'

╔══════════════════════════════════════════════════════════════╗
║           WinBoat Installation for Bentobox                  ║
║     Run Windows Apps Seamlessly on Linux ("Reverse WSL")     ║
╚══════════════════════════════════════════════════════════════╝

EOF

# Beta warning
warning "BETA SOFTWARE - Advanced Users Only"
echo "WinBoat ${WINBOAT_VERSION} is currently in BETA:"
echo "  • Expect occasional bugs and stability issues"
echo "  • Requires GUI desktop environment"
echo "  • Needs ~800MB for prerequisites + 50GB for Windows VM"
echo "  • Requires LOGOUT after install for group permissions"
echo ""
info "✅ Best for: Adobe Suite, Office 365, Professional Windows-only apps"
info "❌ NOT for: Gaming, GPU tasks, or apps that work fine in WINE"
echo ""

# Confirm understanding
read -p "Continue with installation? (yes/no): " confirm
[[ "$confirm" != "yes" ]] && { info "Installation cancelled."; exit 0; }
echo ""

# Check if running in GUI environment
check_gui_environment() {
    info "Checking desktop environment..."
    if [ -z "$DISPLAY" ] && [ -z "$WAYLAND_DISPLAY" ]; then
        warning "No GUI display detected"
        echo "  WinBoat requires a graphical desktop environment to run."
        echo "  Installation can proceed, but you'll need to be logged into"
        echo "  a desktop session to use WinBoat."
        echo ""
        read -p "Continue anyway? (yes/no): " gui_confirm
        [[ "$gui_confirm" != "yes" ]] && exit 0
    else
        success "GUI environment detected"
    fi
}

# Check CPU virtualization
check_virtualization() {
    info "Checking CPU virtualization..."
    if egrep -q '(vmx|svm)' /proc/cpuinfo; then
        local virt_type=$(grep -q 'vmx' /proc/cpuinfo && echo "Intel VT-x" || echo "AMD-V")
        success "CPU virtualization supported (${virt_type})"
        return 0
    else
        error "CPU virtualization not detected"
        echo ""
        echo "Fix: Enable virtualization in BIOS/UEFI settings"
        echo "  1. Reboot and enter BIOS (usually DEL, F2, or F12)"
        echo "  2. Find CPU settings (may be under Advanced/Security)"
        echo "  3. Enable Intel VT-x or AMD-V"
        echo "  4. Save and reboot"
        return 1
    fi
}

# Check RAM
check_ram() {
    info "Checking system memory..."
    local total_ram_gb=$(free -g | awk '/^Mem:/{print $2}')
    local total_ram_mb=$(free -m | awk '/^Mem:/{print $2}')
    
    echo "  → Detected: ${total_ram_mb}MB (${total_ram_gb}GB) RAM"
    
    if [ "$total_ram_gb" -ge "$MIN_RAM_GB" ]; then
        success "RAM check passed"
        return 0
    else
        error "Insufficient RAM (need ${MIN_RAM_GB}GB, have ${total_ram_gb}GB)"
        echo ""
        read -p "Continue anyway? (NOT recommended) (yes/no): " ram_confirm
        [[ "$ram_confirm" == "yes" ]] && { warning "Proceeding with low RAM"; return 0; }
        return 1
    fi
}

# Check disk space
check_disk_space() {
    info "Checking available disk space..."
    local free_space_gb=$(df -BG / | awk 'NR==2 {print $4}' | tr -d 'G')
    
    echo "  → Available: ${free_space_gb}GB on root partition"
    
    if [ "$free_space_gb" -ge "$MIN_DISK_GB" ]; then
        success "Disk space check passed"
        return 0
    else
        error "Insufficient disk space (need ${MIN_DISK_GB}GB, have ${free_space_gb}GB)"
        return 1
    fi
}

# Check Ubuntu version
check_ubuntu_version() {
    info "Checking Ubuntu version..."
    if grep -q "Ubuntu" /etc/os-release; then
        local version=$(grep VERSION_ID /etc/os-release | cut -d'"' -f2)
        echo "  → Ubuntu ${version} detected"
        
        if [[ "$version" == "24.04" ]]; then
            success "Ubuntu version check passed"
        else
            warning "WinBoat is tested on Ubuntu 24.04 (you have ${version})"
        fi
        return 0
    else
        warning "Non-Ubuntu distribution detected (may have compatibility issues)"
        return 0
    fi
}

# Detect existing components
detect_existing_components() {
    info "Detecting existing components..."
    
    local DOCKER_EXISTS=false
    local KVM_EXISTS=false
    local LIBVIRT_EXISTS=false
    local PREREQ_SIZE="~800MB"
    local INSTALL_TIME="3-5 minutes"
    
    # Check Docker
    if command -v docker &> /dev/null; then
        echo "  ✅ Docker already installed ($(docker --version | awk '{print $3}' | tr -d ','))"
        DOCKER_EXISTS=true
        PREREQ_SIZE="~600MB"
        INSTALL_TIME="2-3 minutes"
    else
        echo "  ⚠️  Docker not found (will be installed)"
    fi
    
    # Check KVM
    if lsmod | grep -q kvm; then
        echo "  ✅ KVM modules already loaded"
        KVM_EXISTS=true
    else
        echo "  ⚠️  KVM not loaded (will be configured)"
    fi
    
    # Check libvirt
    if systemctl is-active --quiet libvirtd 2>/dev/null; then
        echo "  ✅ libvirt already running"
        LIBVIRT_EXISTS=true
        PREREQ_SIZE="~400MB"
        INSTALL_TIME="1-2 minutes"
    else
        echo "  ⚠️  libvirt not running (will be installed)"
    fi
    
    echo ""
    info "Estimated installation: ${PREREQ_SIZE}, ${INSTALL_TIME}"
    echo ""
    
    # Return composite status
    if $DOCKER_EXISTS && $LIBVIRT_EXISTS; then
        return 0  # Most components present
    else
        return 1  # Need significant installation
    fi
}

# Install prerequisites
install_prerequisites() {
    info "Installing system prerequisites..."
    echo ""
    
    # Check if Docker needed
    if ! command -v docker &> /dev/null; then
        info "Installing Docker..."
        sudo apt-get update -qq
        sudo DEBIAN_FRONTEND=noninteractive apt-get install -y docker.io docker-compose 2>&1 | grep -E '(Setting up|done)' || true
        sudo systemctl enable --now docker
        success "Docker installed"
    fi
    
    # Install virtualization stack
    info "Installing virtualization stack (QEMU/KVM/libvirt/virt-manager)..."
    sudo apt-get update -qq
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y \
        qemu-kvm \
        libvirt-daemon-system \
        libvirt-clients \
        bridge-utils \
        virt-manager \
        qemu-system-x86 2>&1 | grep -E '(Setting up|done)' || true
    
    # Enable and start services
    sudo systemctl enable libvirtd
    sudo systemctl start libvirtd
    sudo systemctl start virtlogd 2>/dev/null || true
    
    success "Prerequisites installed successfully"
}

# Configure user permissions
configure_permissions() {
    info "Configuring user permissions..."
    
    local user=$(whoami)
    local groups_added=()
    local NEEDS_LOGOUT=false
    
    # Check and add to required groups
    for group in docker kvm libvirt; do
        if ! groups $user | grep -q $group; then
            sudo usermod -aG $group $user
            groups_added+=("$group")
            NEEDS_LOGOUT=true
        fi
    done
    
    if [ ${#groups_added[@]} -gt 0 ]; then
        success "Added user to groups: ${groups_added[*]}"
        echo ""
        warning "LOGOUT REQUIRED"
        echo "  Group changes won't take effect until you logout and login again."
        echo "  You MUST logout before using WinBoat for the first time."
        echo ""
        return 0
    else
        success "User already has all required permissions"
        return 0
    fi
}

# Download and install WinBoat
install_winboat() {
    info "Downloading WinBoat ${WINBOAT_VERSION}..."
    
    # Create local bin directory if needed
    mkdir -p ~/.local/bin
    
    # Download AppImage
    local winboat_path="$HOME/.local/bin/winboat"
    
    if wget -q --show-progress -O "$winboat_path" "$WINBOAT_APPIMAGE_URL"; then
        chmod +x "$winboat_path"
        success "WinBoat downloaded to ~/.local/bin/winboat"
        
        # Verify download
        if file "$winboat_path" | grep -q "ELF 64-bit"; then
            local size=$(ls -lh "$winboat_path" | awk '{print $5}')
            echo "  → File size: $size"
            echo "  → Type: AppImage (portable)"
            success "Download verified"
        else
            error "Downloaded file appears corrupted"
            return 1
        fi
    else
        error "Failed to download WinBoat"
        echo ""
        echo "Manual download instructions:"
        echo "  1. Visit: ${WINBOAT_GITHUB}/releases"
        echo "  2. Download: winboat-${WINBOAT_VERSION#v}-x86_64.AppImage"
        echo "  3. Move to: ~/.local/bin/winboat"
        echo "  4. Run: chmod +x ~/.local/bin/winboat"
        return 1
    fi
    
    # Ensure ~/.local/bin is in PATH
    if ! echo "$PATH" | grep -q "$HOME/.local/bin"; then
        warning "~/.local/bin not in PATH"
        echo "  Adding to ~/.bashrc..."
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
        echo "  → Changes will take effect after logout/login"
    fi
    
    return 0
}

# Create desktop entry
create_desktop_entry() {
    info "Creating desktop entry..."
    
    local desktop_file="$HOME/.local/share/applications/winboat.desktop"
    mkdir -p "$HOME/.local/share/applications"
    
    cat > "$desktop_file" << 'DESKTOP_EOF'
[Desktop Entry]
Name=WinBoat
Comment=Run Windows applications on Linux with seamless integration
Exec=/home/%u/.local/bin/winboat
Icon=winboat
Terminal=false
Type=Application
Categories=System;Emulator;Virtualization;
Keywords=windows;vm;virtual machine;emulator;wine;
StartupNotify=true
DESKTOP_EOF

    # Fix %u in Exec path
    sed -i "s|/home/%u|$HOME|g" "$desktop_file"
    
    success "Desktop entry created"
    echo "  → WinBoat will appear in your applications menu after logout/login"
}

# Final instructions
show_completion_message() {
    echo ""
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║          WinBoat Installation Complete! 🎉                   ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo ""
    
    warning "⚠️  IMPORTANT: LOGOUT AND LOGIN REQUIRED"
    echo ""
    echo "Before using WinBoat, you MUST:"
    echo "  1️⃣  Logout of your current session"
    echo "  2️⃣  Login again (for group permissions to take effect)"
    echo ""
    
    info "After logging back in:"
    echo ""
    echo "🚀 Launch WinBoat:"
    echo "   • From applications menu: Search for 'WinBoat'"
    echo "   • From terminal: winboat"
    echo ""
    echo "📋 First-time setup (in WinBoat):"
    echo "   1. Follow the Windows installation wizard"
    echo "   2. Choose Windows version (recommend Windows 10/11)"
    echo "   3. Allocate VM resources:"
    echo "      - RAM: 4-8GB (more is better)"
    echo "      - CPU: 2-4 cores"
    echo "      - Disk: 40GB minimum"
    echo "   4. Wait 30-60 minutes for Windows to install"
    echo "   5. Start using Windows apps!"
    echo ""
    
    info "💡 Tips:"
    echo "   • Your Linux home directory is accessible from Windows"
    echo "   • Windows apps appear as native Linux windows"
    echo "   • Clipboard works between Linux and Windows"
    echo "   • USB passthrough available (experimental, in settings)"
    echo ""
    
    info "📚 Resources:"
    echo "   • Documentation: ${WINBOAT_WEBSITE}"
    echo "   • GitHub: ${WINBOAT_GITHUB}"
    echo "   • Community: Discord (link on website)"
    echo ""
    
    info "🔧 Advanced:"
    echo "   • Manage VMs: virt-manager (installed)"
    echo "   • Docker containers: docker ps"
    echo "   • Config location: ~/.winboat/"
    echo ""
}

# Main installation flow
main() {
    local failed_checks=0
    
    echo "═══════════════════════════════════════════════════════════════"
    echo "  System Requirements Check"
    echo "═══════════════════════════════════════════════════════════════"
    echo ""
    
    # Run all system checks
    check_ubuntu_version || ((failed_checks++))
    check_gui_environment || ((failed_checks++))
    check_virtualization || ((failed_checks++))
    check_ram || ((failed_checks++))
    check_disk_space || ((failed_checks++))
    
    echo ""
    
    # Exit if critical checks failed
    if [ $failed_checks -gt 0 ]; then
        error "System requirements not met (${failed_checks} checks failed)"
        echo ""
        info "Please address the issues above and try again."
        exit 1
    fi
    
    success "All system requirements met!"
    echo ""
    
    # Detect existing components
    detect_existing_components
    
    echo "═══════════════════════════════════════════════════════════════"
    echo "  Ready to Install"
    echo "═══════════════════════════════════════════════════════════════"
    echo ""
    
    read -p "Proceed with installation? (yes/no): " install_confirm
    [[ "$install_confirm" != "yes" ]] && { info "Installation cancelled."; exit 0; }
    
    echo ""
    echo "═══════════════════════════════════════════════════════════════"
    echo "  Installing Components"
    echo "═══════════════════════════════════════════════════════════════"
    echo ""
    
    # Install prerequisites
    install_prerequisites || {
        error "Failed to install prerequisites"
        exit 1
    }
    
    echo ""
    
    # Configure permissions
    configure_permissions || {
        error "Failed to configure permissions"
        exit 1
    }
    
    echo ""
    
    # Install WinBoat
    install_winboat || {
        error "Failed to download WinBoat"
        echo ""
        info "Prerequisites are installed. Try manual download."
        exit 1
    }
    
    echo ""
    
    # Create desktop entry
    create_desktop_entry
    
    echo ""
    
    # Show completion message
    show_completion_message
    
    success "Installation script completed successfully!"
    echo ""
    warning "Remember: LOGOUT and LOGIN before using WinBoat!"
}

# Run main installation
main

exit 0

