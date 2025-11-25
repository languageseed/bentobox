#!/bin/bash
# Debian Distribution Plugin
# Supports: Debian 12 (Bookworm)+, Raspbian

# Get the distros directory
BENTOBOX_DISTROS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source Ubuntu plugin as base (Debian is very similar to Ubuntu)
source "$BENTOBOX_DISTROS_DIR/ubuntu.sh"

# ============================================================================
# DEBIAN-SPECIFIC OVERRIDES
# ============================================================================

distro_verify() {
    # Check Debian version
    if [[ "$BENTOBOX_DISTRO_ID" == "debian" ]] || [[ "$BENTOBOX_DISTRO_ID" == "raspbian" ]]; then
        local major_version="${BENTOBOX_DISTRO_VERSION%%.*}"
        if [ "$major_version" -lt 13 ]; then
            if [ "$major_version" -eq 12 ]; then
                distro_warn "Debian 12 (Bookworm) detected - officially requires Debian 13+"
                distro_info "Debian 12 may work but some packages might be unavailable"
            else
                distro_error "Debian 13 (Trixie)+ required (detected: $BENTOBOX_DISTRO_VERSION)"
                return 1
            fi
        fi
        
        distro_info "Debian $BENTOBOX_DISTRO_VERSION detected"
    fi
    
    # Check architecture
    local arch=$(uname -m)
    if [[ "$arch" != "x86_64" ]] && [[ "$arch" != "aarch64" ]] && [[ "$arch" != "armv7l" ]]; then
        distro_warn "Architecture $arch may not be fully supported"
    fi
    
    return 0
}

distro_add_repo() {
    local type="$1"
    local name="$2"
    
    case "$type" in
        ppa)
            # PPAs don't work on Debian, try to handle gracefully
            distro_warn "PPAs are not supported on Debian"
            distro_info "Consider adding the repository manually or installing from .deb"
            distro_info "Some packages may be available in Debian Testing or Backports"
            return 1
            ;;
        
        debian-testing)
            # Enable Debian Testing for specific packages
            distro_info "Adding Debian Testing repository"
            echo "deb http://deb.debian.org/debian testing main" | \
                sudo tee /etc/apt/sources.list.d/bentobox-testing.list >/dev/null
            
            # Set up pinning to prevent accidental upgrades
            cat <<'EOF' | sudo tee /etc/apt/preferences.d/bentobox-testing >/dev/null
Package: *
Pin: release a=testing
Pin-Priority: 100
EOF
            sudo apt update
            distro_info "To install from testing, use: sudo apt install -t testing <package>"
            ;;
        
        debian-backports)
            # Enable Debian Backports
            local codename=$(lsb_release -sc 2>/dev/null || echo "bookworm")
            distro_info "Adding Debian Backports repository"
            echo "deb http://deb.debian.org/debian ${codename}-backports main" | \
                sudo tee /etc/apt/sources.list.d/bentobox-backports.list >/dev/null
            sudo apt update
            distro_info "To install from backports, use: sudo apt install -t ${codename}-backports <package>"
            ;;
        
        custom)
            # Call parent implementation
            distro_info "Adding custom repository"
            echo "$name" | sudo tee "/etc/apt/sources.list.d/bentobox-custom.list" >/dev/null
            sudo apt update
            ;;
        
        *)
            distro_error "Unknown repository type: $type"
            distro_info "Supported types: debian-testing, debian-backports, custom"
            return 1
            ;;
    esac
}

distro_setup_desktop() {
    distro_info "Debian desktop environment detected"
    
    # Debian can use various desktop environments
    if command -v gnome-shell &>/dev/null; then
        distro_success "GNOME desktop detected"
        return 0
    elif command -v plasmashell &>/dev/null; then
        distro_warn "KDE Plasma detected. Some GNOME-specific features may not work."
        return 0
    elif command -v xfce4-session &>/dev/null; then
        distro_warn "XFCE detected. Some GNOME-specific features may not work."
        return 0
    elif command -v mate-session &>/dev/null; then
        distro_warn "MATE detected. Some GNOME-specific features may not work."
        return 0
    elif command -v cinnamon-session &>/dev/null; then
        distro_warn "Cinnamon detected. Some GNOME-specific features may not work."
        return 0
    else
        distro_warn "Could not detect desktop environment"
        return 1
    fi
}

distro_map_package() {
    local generic_name="$1"
    
    # Most Debian packages have the same names as Ubuntu
    # Call parent implementation
    case "$generic_name" in
        # Override any Debian-specific differences here
        # For now, Debian uses same names as Ubuntu for most packages
        *)
            # Call Ubuntu's mapping
            source "$BENTOBOX_DISTROS_DIR/ubuntu.sh"
            distro_map_package "$generic_name"
            ;;
    esac
}

# ============================================================================
# DEBIAN-SPECIFIC HELPERS
# ============================================================================

# Check if running on Raspbian
is_raspbian() {
    [[ "$BENTOBOX_DISTRO_ID" == "raspbian" ]]
}

# Check if running on Raspberry Pi
is_raspberry_pi() {
    [ -f /proc/device-tree/model ] && grep -q "Raspberry Pi" /proc/device-tree/model
}

# Get Debian codename
get_debian_codename() {
    lsb_release -sc 2>/dev/null || echo "bookworm"
}

