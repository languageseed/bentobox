#!/bin/bash
# WinBoat Installation Script for Bentobox
# Status: DRAFT - DO NOT USE IN PRODUCTION
# Requires: Ubuntu 24.04+, 8GB+ RAM, Virtualization support

set -e

# Source bentobox helpers (when integrated)
# source $OMAKUB_PATH/defaults/bash/shell-helpers.sh

# Configuration
WINBOAT_NAME="WinBoat"
WINBOAT_DESC="Run Windows applications on Linux with seamless integration"
MIN_RAM_GB=8
MIN_DISK_GB=50
WINBOAT_WEBSITE="https://www.winboat.app/"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

success() {
    echo -e "${GREEN}✅ $1${NC}"
}

warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

error() {
    echo -e "${RED}❌ $1${NC}"
}

# Banner
echo ""
echo "╔══════════════════════════════════════════════════════════╗"
echo "║          WinBoat Installation for Bentobox              ║"
echo "║    Run Windows Applications Seamlessly on Linux         ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""

# Beta warning
warning "BETA SOFTWARE WARNING"
echo "WinBoat is currently in BETA status. This means:"
echo "  • Occasional bugs and instability expected"
echo "  • Requires troubleshooting comfort level"
echo "  • Not suitable for production-critical workflows"
echo "  • Current iteration not representative of final product"
echo ""
info "Best for: Adobe Suite, Office 365, Professional Windows apps"
info "NOT for: Gaming, GPU-intensive tasks, or critical production use"
echo ""

# Ask for confirmation
read -p "Do you understand and wish to continue? (yes/no): " confirm
if [[ "$confirm" != "yes" ]]; then
    info "Installation cancelled."
    exit 0
fi

echo ""

# Function: Check CPU virtualization
check_virtualization() {
    info "Checking CPU virtualization support..."
    
    if egrep -q '(vmx|svm)' /proc/cpuinfo; then
        success "CPU virtualization supported"
        
        # Check if it's Intel or AMD
        if grep -q 'vmx' /proc/cpuinfo; then
            echo "  → Intel VT-x detected"
        elif grep -q 'svm' /proc/cpuinfo; then
            echo "  → AMD-V detected"
        fi
        return 0
    else
        error "CPU virtualization not detected"
        echo ""
        echo "This could mean:"
        echo "  1. Your CPU doesn't support virtualization"
        echo "  2. Virtualization is disabled in BIOS/UEFI"
        echo ""
        echo "To enable virtualization:"
        echo "  1. Reboot and enter BIOS/UEFI (usually DEL, F2, or F12 key)"
        echo "  2. Find CPU settings (may be under Advanced or Security)"
        echo "  3. Enable Intel VT-x or AMD-V"
        echo "  4. Save and reboot"
        echo ""
        return 1
    fi
}

# Function: Check RAM
check_ram() {
    info "Checking system memory..."
    
    local total_ram_gb=$(free -g | awk '/^Mem:/{print $2}')
    local total_ram_mb=$(free -m | awk '/^Mem:/{print $2}')
    
    echo "  → Detected: ${total_ram_mb}MB (${total_ram_gb}GB) RAM"
    
    if [ "$total_ram_gb" -ge "$MIN_RAM_GB" ]; then
        success "RAM check passed"
        return 0
    else
        error "Insufficient RAM"
        echo "  → Required: ${MIN_RAM_GB}GB minimum"
        echo "  → Detected: ${total_ram_gb}GB"
        echo ""
        echo "WinBoat requires significant memory to run Windows VM + host OS."
        echo "Performance will be poor with less than ${MIN_RAM_GB}GB RAM."
        echo ""
        read -p "Continue anyway? (not recommended) (yes/no): " ram_confirm
        if [[ "$ram_confirm" == "yes" ]]; then
            warning "Proceeding with insufficient RAM - expect poor performance"
            return 0
        else
            return 1
        fi
    fi
}

# Function: Check disk space
check_disk_space() {
    info "Checking available disk space..."
    
    local free_space_gb=$(df -BG / | awk 'NR==2 {print $4}' | tr -d 'G')
    
    echo "  → Available: ${free_space_gb}GB free on root partition"
    
    if [ "$free_space_gb" -ge "$MIN_DISK_GB" ]; then
        success "Disk space check passed"
        return 0
    else
        error "Insufficient disk space"
        echo "  → Required: ${MIN_DISK_GB}GB minimum"
        echo "  → Available: ${free_space_gb}GB"
        echo ""
        echo "WinBoat needs space for:"
        echo "  • Windows VM disk image (25-40GB)"
        echo "  • Docker containers and volumes"
        echo "  • Windows applications"
        echo ""
        return 1
    fi
}

# Function: Check Ubuntu version
check_ubuntu_version() {
    info "Checking Ubuntu version..."
    
    if grep -q "Ubuntu" /etc/os-release; then
        local version=$(grep VERSION_ID /etc/os-release | cut -d'"' -f2)
        echo "  → Ubuntu ${version} detected"
        
        if [[ "$version" == "24.04" ]]; then
            success "Ubuntu version check passed"
            return 0
        else
            warning "WinBoat is tested on Ubuntu 24.04"
            echo "  → Your version: ${version}"
            echo "  → May work but not officially supported"
            return 0
        fi
    else
        warning "Non-Ubuntu distribution detected"
        echo "WinBoat is designed for Ubuntu. Compatibility not guaranteed."
        return 0
    fi
}

# Function: Check if KVM module is available
check_kvm_module() {
    info "Checking KVM kernel module..."
    
    if lsmod | grep -q kvm; then
        success "KVM module loaded"
        
        if lsmod | grep -q kvm_intel; then
            echo "  → kvm_intel module loaded"
        elif lsmod | grep -q kvm_amd; then
            echo "  → kvm_amd module loaded"
        fi
        return 0
    else
        warning "KVM module not currently loaded"
        echo "  → Will be loaded after prerequisites installation"
        return 0
    fi
}

# Function: Install prerequisites
install_prerequisites() {
    info "Installing system prerequisites..."
    echo ""
    
    # Update package list
    info "Updating package lists..."
    sudo apt-get update -qq
    
    # Install QEMU/KVM virtualization stack
    info "Installing QEMU/KVM virtualization stack..."
    echo "  → qemu-kvm: Kernel-based Virtual Machine"
    echo "  → libvirt: Virtualization management"
    echo "  → virt-manager: Virtual Machine Manager (GUI)"
    sudo apt-get install -y \
        qemu-kvm \
        libvirt-daemon-system \
        libvirt-clients \
        bridge-utils \
        virt-manager 2>&1 | grep -v "^Reading"
    
    # Install Docker if not present
    if ! command -v docker &> /dev/null; then
        info "Installing Docker..."
        sudo apt-get install -y \
            docker.io \
            docker-compose 2>&1 | grep -v "^Reading"
        
        # Enable and start Docker
        sudo systemctl enable docker
        sudo systemctl start docker
        success "Docker installed and started"
    else
        info "Docker already installed"
    fi
    
    # Enable and start libvirtd
    sudo systemctl enable libvirtd
    sudo systemctl start libvirtd
    
    success "Prerequisites installed successfully"
}

# Function: Configure user permissions
configure_permissions() {
    info "Configuring user permissions..."
    
    local user=$(whoami)
    local groups_added=()
    
    # Check and add to docker group
    if ! groups $user | grep -q docker; then
        sudo usermod -aG docker $user
        groups_added+=("docker")
    fi
    
    # Check and add to kvm group
    if ! groups $user | grep -q kvm; then
        sudo usermod -aG kvm $user
        groups_added+=("kvm")
    fi
    
    # Check and add to libvirt group
    if ! groups $user | grep -q libvirt; then
        sudo usermod -aG libvirt $user
        groups_added+=("libvirt")
    fi
    
    if [ ${#groups_added[@]} -gt 0 ]; then
        success "Added user to groups: ${groups_added[*]}"
        warning "You MUST LOG OUT and LOG BACK IN for group changes to take effect!"
        return 0
    else
        info "User already has required permissions"
        return 0
    fi
}

# Function: Download and install WinBoat
install_winboat() {
    info "Downloading WinBoat..."
    
    # Create temp directory
    local temp_dir=$(mktemp -d)
    cd "$temp_dir"
    
    # NOTE: These URLs are placeholders
    # Actual download URLs need to be determined from https://www.winboat.app/
    # The website should have direct download links for each platform
    
    # For Ubuntu/Debian, we want the .deb package
    local deb_file="winboat_latest_amd64.deb"
    local download_url="https://www.winboat.app/download/${deb_file}"
    
    # Attempt download
    info "Downloading from ${WINBOAT_WEBSITE}..."
    
    # Try to download (this will fail with placeholder URL)
    if wget -q --show-progress -O "$deb_file" "$download_url" 2>&1; then
        success "Download complete"
    else
        error "Automated download failed"
        echo ""
        echo "Please download WinBoat manually:"
        echo "  1. Visit: ${WINBOAT_WEBSITE}"
        echo "  2. Click Downloads"
        echo "  3. Download the Ubuntu/Debian package (.deb)"
        echo "  4. Install with: sudo dpkg -i winboat_*.deb"
        echo ""
        cd - > /dev/null
        rm -rf "$temp_dir"
        return 1
    fi
    
    # Install the package
    info "Installing WinBoat package..."
    sudo dpkg -i "$deb_file" 2>&1 || {
        info "Resolving dependencies..."
        sudo apt-get install -f -y
    }
    
    success "WinBoat package installed"
    
    # Cleanup
    cd - > /dev/null
    rm -rf "$temp_dir"
    
    return 0
}

# Function: Post-installation setup
post_install_setup() {
    info "Performing post-installation setup..."
    
    # Verify installation
    if command -v winboat &> /dev/null; then
        success "WinBoat executable found"
    else
        warning "WinBoat executable not in PATH"
        echo "  → You may need to log out and back in"
    fi
    
    # Create desktop entry if needed (usually done by package)
    local desktop_file="$HOME/.local/share/applications/winboat.desktop"
    if [ ! -f "$desktop_file" ] && [ ! -f "/usr/share/applications/winboat.desktop" ]; then
        info "Creating desktop entry..."
        mkdir -p "$HOME/.local/share/applications"
        cat > "$desktop_file" << 'EOF'
[Desktop Entry]
Name=WinBoat
Comment=Run Windows applications on Linux
Exec=winboat
Icon=winboat
Terminal=false
Type=Application
Categories=System;Emulator;Virtualization;
Keywords=windows;vm;virtual machine;emulator;
StartupNotify=true
EOF
        success "Desktop entry created"
    fi
}

# Function: Display next steps
show_next_steps() {
    echo ""
    echo "╔══════════════════════════════════════════════════════════╗"
    echo "║            WinBoat Installation Complete! 🎉            ║"
    echo "╚══════════════════════════════════════════════════════════╝"
    echo ""
    
    warning "IMPORTANT: LOGOUT AND LOGIN REQUIRED"
    echo "You must log out and log back in for group permissions to take effect."
    echo ""
    
    info "After logging back in:"
    echo ""
    echo "1️⃣  Launch WinBoat from your applications menu"
    echo "   (Search for 'WinBoat' in your app launcher)"
    echo ""
    echo "2️⃣  Follow the Windows installation wizard"
    echo "   • Choose Windows version"
    echo "   • Configure VM resources (RAM, CPU, disk)"
    echo "   • Wait 30-60 minutes for installation to complete"
    echo ""
    echo "3️⃣  Start using Windows applications!"
    echo "   • Windows apps appear as native Linux windows"
    echo "   • Your Linux home directory is accessible from Windows"
    echo "   • Install apps as you normally would in Windows"
    echo ""
    
    info "Need help?"
    echo "  • Documentation: ${WINBOAT_WEBSITE}"
    echo "  • FAQ: ${WINBOAT_WEBSITE}#faq"
    echo "  • Community: Discord (link on website)"
    echo ""
    
    info "Quick Tips:"
    echo "  • Allocate at least 4GB RAM to Windows VM"
    echo "  • Give VM at least 2 CPU cores"
    echo "  • Keep Windows updated for best performance"
    echo "  • Use USB passthrough for peripherals (experimental)"
    echo ""
}

# Main installation flow
main() {
    local failed_checks=0
    
    # Run all system checks
    echo "═══════════════════════════════════════════════════════════"
    echo "  System Requirements Check"
    echo "═══════════════════════════════════════════════════════════"
    echo ""
    
    check_ubuntu_version || ((failed_checks++))
    check_virtualization || ((failed_checks++))
    check_ram || ((failed_checks++))
    check_disk_space || ((failed_checks++))
    check_kvm_module || true  # Don't fail on this one
    
    echo ""
    
    # Exit if critical checks failed
    if [ $failed_checks -gt 0 ]; then
        error "System requirements not met. Cannot continue."
        echo ""
        info "Please address the issues above and try again."
        exit 1
    fi
    
    success "All system requirements met!"
    echo ""
    
    # Confirm installation
    echo "═══════════════════════════════════════════════════════════"
    echo "  Ready to Install"
    echo "═══════════════════════════════════════════════════════════"
    echo ""
    echo "The following will be installed:"
    echo "  • QEMU/KVM (virtualization hypervisor)"
    echo "  • libvirt (VM management framework)"
    echo "  • virt-manager (Virtual Machine Manager GUI)"
    echo "  • Docker (containerization platform)"
    echo "  • WinBoat application (seamless Windows integration)"
    echo ""
    
    read -p "Proceed with installation? (yes/no): " install_confirm
    if [[ "$install_confirm" != "yes" ]]; then
        info "Installation cancelled."
        exit 0
    fi
    
    echo ""
    echo "═══════════════════════════════════════════════════════════"
    echo "  Installing Components"
    echo "═══════════════════════════════════════════════════════════"
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
        error "Failed to install WinBoat"
        echo ""
        info "Prerequisites are installed. You can try manual installation:"
        echo "  1. Visit ${WINBOAT_WEBSITE}"
        echo "  2. Download the package for your system"
        echo "  3. Install manually"
        exit 1
    }
    
    echo ""
    
    # Post-installation
    post_install_setup
    
    echo ""
    
    # Show next steps
    show_next_steps
    
    success "Installation script completed successfully!"
}

# Run main installation
main

exit 0

