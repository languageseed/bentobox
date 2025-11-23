# WinBoat Deployment Notes for Bentobox

## Integration Strategy

### Positioning in Bentobox
- **Category**: Desktop Applications → Optional → Advanced Tools
- **User Level**: Advanced (not recommended for beginners)
- **Installation Type**: Optional, explicit opt-in
- **Status Label**: "Beta - Advanced Users Only"

## Installation Script Structure

### Pre-Installation Checks

```bash
#!/bin/bash
# app-winboat.sh - WinBoat installation for bentobox

set -e

# Color definitions
source $OMAKUB_PATH/defaults/bash/shell-helpers.sh

# Check 1: System requirements
check_system_requirements() {
    local errors=0
    
    # Check CPU virtualization
    if ! egrep -q '(vmx|svm)' /proc/cpuinfo; then
        echo "❌ CPU virtualization not supported or not enabled in BIOS"
        errors=1
    fi
    
    # Check RAM (minimum 8GB recommended)
    local total_ram=$(free -g | awk '/^Mem:/{print $2}')
    if [ "$total_ram" -lt 8 ]; then
        echo "⚠️  Warning: Less than 8GB RAM detected. WinBoat may not perform well."
        echo "   Detected: ${total_ram}GB RAM"
    fi
    
    # Check disk space (need at least 50GB free)
    local free_space=$(df -BG / | awk 'NR==2 {print $4}' | tr -d 'G')
    if [ "$free_space" -lt 50 ]; then
        echo "❌ Insufficient disk space. Need at least 50GB free."
        echo "   Available: ${free_space}GB"
        errors=1
    fi
    
    # Check Ubuntu version
    if ! grep -q "24.04" /etc/os-release; then
        echo "⚠️  Warning: WinBoat is tested on Ubuntu 24.04. Your version may not be supported."
    fi
    
    if [ $errors -gt 0 ]; then
        return 1
    fi
    
    return 0
}

# Check 2: KVM support
check_kvm_support() {
    if ! lsmod | grep -q kvm; then
        echo "ℹ️  KVM module not loaded. Will install and load."
        return 1
    fi
    return 0
}

# Main installation function
install_winboat() {
    echo "🚀 Installing WinBoat..."
    echo ""
    echo "⚠️  IMPORTANT: WinBoat is currently in BETA"
    echo "   • Expect occasional bugs and issues"
    echo "   • Requires significant system resources (8GB+ RAM)"
    echo "   • Not suitable for gaming or GPU-intensive tasks"
    echo "   • Best for: Office, Adobe Suite, Professional Windows apps"
    echo ""
    
    # Prompt for confirmation
    read -p "Continue with installation? (y/N): " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        echo "Installation cancelled."
        exit 0
    fi
    
    # System requirements check
    if ! check_system_requirements; then
        echo ""
        echo "❌ System requirements not met. Installation cannot continue."
        exit 1
    fi
    
    echo "✅ System requirements check passed"
    echo ""
    
    # Install prerequisites
    echo "📦 Installing prerequisites..."
    
    # Install QEMU/KVM virtualization stack
    sudo apt-get update
    sudo apt-get install -y \
        qemu-kvm \
        libvirt-daemon-system \
        libvirt-clients \
        bridge-utils \
        virt-manager  # Virtual Machine Manager - GUI for VM management
    
    # Install Docker if not present
    if ! command -v docker &> /dev/null; then
        echo "📦 Installing Docker..."
        sudo apt-get install -y docker.io docker-compose
        sudo systemctl enable docker
        sudo systemctl start docker
    fi
    
    # Add user to required groups
    echo "👤 Configuring user permissions..."
    sudo usermod -aG docker,kvm,libvirt $USER
    
    # Enable and start services
    sudo systemctl enable libvirtd
    sudo systemctl start libvirtd
    
    # Download and install WinBoat
    echo "📥 Downloading WinBoat..."
    
    # For Ubuntu, we'll use the .deb package
    local WINBOAT_DEB="winboat_latest_amd64.deb"
    local DOWNLOAD_URL="https://www.winboat.app/download/$WINBOAT_DEB"
    
    # Download to temp directory
    local TEMP_DIR=$(mktemp -d)
    cd $TEMP_DIR
    
    # Note: Update with actual download URL from website
    # This is a placeholder - actual URL needs to be determined from winboat.app
    wget -O $WINBOAT_DEB "$DOWNLOAD_URL" || {
        echo "❌ Failed to download WinBoat"
        echo "   Please visit https://www.winboat.app/ to download manually"
        exit 1
    }
    
    # Install package
    echo "📦 Installing WinBoat package..."
    sudo dpkg -i $WINBOAT_DEB || {
        echo "📦 Resolving dependencies..."
        sudo apt-get install -f -y
    }
    
    # Clean up
    cd -
    rm -rf $TEMP_DIR
    
    # Create desktop entry if not present
    create_desktop_entry
    
    echo ""
    echo "✅ WinBoat installation complete!"
    echo ""
    echo "⚠️  IMPORTANT: You must LOG OUT and LOG BACK IN for group changes to take effect!"
    echo ""
    echo "After logging back in:"
    echo "  1. Launch WinBoat from your applications menu"
    echo "  2. Follow the setup wizard to install Windows"
    echo "  3. Visit https://www.winboat.app/ for documentation"
    echo ""
    echo "Need help? Join the WinBoat Discord community (link on website)"
}

# Create desktop entry
create_desktop_entry() {
    # This may already be created by the .deb package
    # This is a fallback
    local DESKTOP_FILE="$HOME/.local/share/applications/winboat.desktop"
    
    if [ ! -f "$DESKTOP_FILE" ]; then
        cat > "$DESKTOP_FILE" << EOF
[Desktop Entry]
Name=WinBoat
Comment=Run Windows applications on Linux
Exec=winboat
Icon=winboat
Terminal=false
Type=Application
Categories=System;Emulator;Virtualization;
StartupNotify=true
EOF
    fi
}

# Run installation
install_winboat
```

### Uninstallation Script

```bash
#!/bin/bash
# uninstall-winboat.sh

set -e

echo "🗑️  Uninstalling WinBoat..."
echo ""
echo "This will:"
echo "  • Remove WinBoat application"
echo "  • Stop all WinBoat containers"
echo "  • Remove WinBoat Docker volumes (Windows VM data)"
echo "  • Clean up configuration files"
echo ""

read -p "Continue? (y/N): " confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "Uninstallation cancelled."
    exit 0
fi

# Stop WinBoat containers
if [ -d "$HOME/.winboat" ]; then
    echo "🛑 Stopping WinBoat containers..."
    cd "$HOME/.winboat"
    if [ -f "docker-compose.yml" ]; then
        docker-compose down || true
    fi
fi

# Remove Docker volumes
echo "🗑️  Removing Docker volumes..."
docker volume ls | grep winboat | awk '{print $2}' | xargs -r docker volume rm || true

# Remove application
echo "📦 Removing WinBoat package..."
sudo apt-get remove -y winboat || true
sudo apt-get autoremove -y

# Remove configuration
echo "🗑️  Removing configuration files..."
rm -rf "$HOME/.winboat"
rm -rf "$HOME/.config/winboat"
rm -f "$HOME/.local/share/applications/winboat.desktop"

echo ""
echo "✅ WinBoat uninstalled successfully"
echo ""
echo "Note: QEMU, Docker, and other system dependencies were NOT removed"
echo "      as they may be used by other applications."
echo ""
echo "To remove these manually:"
echo "  sudo apt-get remove qemu-kvm libvirt-daemon-system"
```

## User Documentation

### What to Include in Bentobox Docs

#### 1. When to Use WinBoat
- Running professional Windows apps (Adobe Suite, Office 365, Affinity)
- Windows development tools
- Apps that don't work with WINE/CrossOver
- Peripheral configuration software (with USB passthrough)

#### 2. When NOT to Use WinBoat
- Gaming (especially anti-cheat games)
- GPU-intensive applications
- When WINE/CrossOver works fine
- Low-resource systems (<8GB RAM)

#### 3. Alternatives to Consider First
- **WINE**: For most Windows apps (lighter weight)
- **Bottles**: User-friendly WINE frontend
- **PlayOnLinux/Lutris**: For gaming
- **Web versions**: Many apps have web versions (Office 365 online)
- **Linux alternatives**: Native Linux apps when possible

### Quick Start Guide

```markdown
# WinBoat Quick Start

## Before You Start
- Ensure you have 8GB+ RAM
- Verify 50GB+ free disk space
- Enable virtualization in BIOS
- Expect beta-quality software

## Installation
WinBoat is available in the bentobox Optional Apps menu:
- Desktop Applications → Advanced Tools → WinBoat

## First Launch
1. Log out and back in after installation (required for permissions)
2. Launch WinBoat from applications menu
3. Follow the Windows installation wizard
4. Choose Windows version and VM resources
5. Wait 30-60 minutes for Windows to install
6. Start using Windows apps!

## Installing Windows Applications
1. Open WinBoat
2. Install apps as you would on Windows
3. Windows will appear as Linux windows

## Filesystem Access
Your Linux home directory is automatically mounted in Windows
at Z:\ drive (or similar). You can access all your Linux files
from Windows apps.

## Troubleshooting
- Performance issues: Increase VM RAM in WinBoat settings
- Display issues: Check RDP connection settings
- USB not working: Enable experimental USB passthrough
- Visit https://www.winboat.app/ for more help
```

## Integration Checklist

### Pre-Launch Requirements
- [ ] Complete full testing per TESTING_PLAN.md
- [ ] Verify installation script works on clean Ubuntu 24.04
- [ ] Verify uninstallation leaves system clean
- [ ] Test with various hardware configurations
- [ ] Document all known issues
- [ ] Create troubleshooting FAQ
- [ ] Get community feedback (beta testers)

### Installation Script Integration
- [ ] Add to `omakub/install/desktop/optional/`
- [ ] Follow naming convention: `app-winboat.sh`
- [ ] Use bentobox shell helpers
- [ ] Include comprehensive pre-checks
- [ ] Add clear user warnings
- [ ] Handle errors gracefully

### Uninstallation Script
- [ ] Add to `omakub/uninstall/`
- [ ] Clean removal of all components
- [ ] Preserve user data (with option to remove)
- [ ] Remove desktop entries

### Documentation Updates
- [ ] Add to optional apps list in README
- [ ] Mark as "Beta" or "Advanced"
- [ ] Create dedicated WinBoat doc page
- [ ] Add to FAQ
- [ ] Include system requirements table
- [ ] Add troubleshooting section

### Terminal Menu Integration
- [ ] Add to appropriate category
- [ ] Clear beta/advanced labeling
- [ ] Include brief description
- [ ] Show system requirements

## Risk Mitigation

### Potential Issues & Solutions

#### Issue: Beta Software Instability
**Mitigation**:
- Clear labeling as beta
- Explicit warnings during installation
- Easy uninstallation process
- Link to official support channels

#### Issue: High Resource Usage
**Mitigation**:
- Pre-installation RAM/disk checks
- Clear system requirements in docs
- Performance optimization tips
- VM resource configuration guidance

#### Issue: Virtualization Not Available
**Mitigation**:
- Check at installation time
- Clear error messages
- Link to BIOS configuration guides
- Offer alternatives (WINE, Bottles)

#### Issue: Docker Permission Issues
**Mitigation**:
- Automatic group addition
- Clear logout/login requirement
- Verification script for permissions
- Troubleshooting steps in docs

#### Issue: Complex Troubleshooting
**Mitigation**:
- Comprehensive FAQ
- Link to official Discord/community
- Common issue database
- Diagnostic script to check configuration

## Success Metrics

### Track During Beta Period
- Installation success rate
- User feedback/satisfaction
- Common issues reported
- Support burden on bentobox maintainers
- Usage statistics (if privacy-respecting method available)

### Criteria for Continued Inclusion
- > 80% installation success rate
- < 10% critical issues
- Active upstream development
- Responsive community support
- Positive user feedback

## Maintenance Plan

### Regular Tasks
- [ ] Monitor WinBoat releases
- [ ] Test updates before bentobox integration
- [ ] Update installation script for new versions
- [ ] Review and update documentation
- [ ] Monitor community for common issues
- [ ] Update FAQ based on user questions

### Review Schedule
- **Monthly**: Check for updates and critical issues
- **Quarterly**: Review user feedback and success metrics
- **Annually**: Reassess inclusion in bentobox

## Contact & Resources

- **Upstream Project**: https://www.winboat.app/
- **Community**: Discord (link on website)
- **GitHub**: [Check website for repository link]
- **License**: MIT (open source)

---

**Document Version**: 1.0  
**Last Updated**: November 22, 2024  
**Status**: Draft - Pending Testing

