#!/bin/bash
# Ubuntu Distribution Plugin
# Supports: Ubuntu 24.04+, Pop!_OS, Elementary OS, Linux Mint, KDE Neon

# Get the distros directory
BENTOBOX_DISTROS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source base interface
source "$BENTOBOX_DISTROS_DIR/base.sh"

# ============================================================================
# UBUNTU-SPECIFIC IMPLEMENTATION
# ============================================================================

distro_verify() {
    # Check Ubuntu version (or derivatives)
    case "$BENTOBOX_DISTRO_ID" in
        ubuntu)
            local major_version="${BENTOBOX_DISTRO_VERSION%%.*}"
            if [ "$major_version" -lt 24 ]; then
                distro_error "Ubuntu 24.04+ required (detected: $BENTOBOX_DISTRO_VERSION)"
                return 1
            fi
            ;;
        pop|elementary|mint|neon)
            # Ubuntu derivatives are generally OK
            distro_info "Ubuntu derivative detected: $BENTOBOX_DISTRO_ID"
            ;;
    esac
    
    # Check architecture
    local arch=$(uname -m)
    if [[ "$arch" != "x86_64" ]] && [[ "$arch" != "aarch64" ]]; then
        distro_warn "Architecture $arch may not be fully supported"
    fi
    
    return 0
}

distro_pkg_update() {
    sudo apt update
}

distro_pkg_upgrade() {
    sudo apt upgrade -y
}

distro_pkg_install() {
    local packages=("$@")
    
    # Map generic names to Ubuntu-specific names
    local mapped_packages=()
    for pkg in "${packages[@]}"; do
        mapped_packages+=("$(distro_map_package "$pkg")")
    done
    
    sudo apt install -y "${mapped_packages[@]}"
}

distro_pkg_remove() {
    local packages=("$@")
    sudo apt remove -y "${packages[@]}"
}

distro_pkg_is_installed() {
    local package="$1"
    dpkg -l | grep -q "^ii  $package "
}

distro_install_binary() {
    local url="$1"
    
    # Check if it's a .deb file
    if [[ "$url" == *.deb ]]; then
        local temp_deb=$(mktemp --suffix=.deb)
        distro_info "Downloading $url..."
        
        if distro_download "$url" "$temp_deb"; then
            distro_info "Installing .deb package..."
            sudo dpkg -i "$temp_deb"
            
            # Fix dependencies if needed
            sudo apt-get install -f -y
            
            rm "$temp_deb"
            return 0
        else
            distro_error "Failed to download package"
            rm -f "$temp_deb"
            return 1
        fi
    else
        distro_error "Ubuntu plugin can only install .deb packages"
        distro_info "URL must end with .deb"
        return 1
    fi
}

distro_add_repo() {
    local type="$1"
    local name="$2"
    
    case "$type" in
        ppa)
            distro_info "Adding PPA: $name"
            sudo add-apt-repository -y "ppa:$name"
            sudo apt update
            ;;
        custom)
            # For custom repos, name should be full repo line
            distro_info "Adding custom repository"
            echo "$name" | sudo tee "/etc/apt/sources.list.d/bentobox-custom.list" >/dev/null
            sudo apt update
            ;;
        *)
            distro_error "Unknown repository type: $type"
            distro_info "Supported types: ppa, custom"
            return 1
            ;;
    esac
}

distro_map_package() {
    local generic_name="$1"
    
    # Ubuntu-specific package name mappings
    case "$generic_name" in
        # Python packages
        python-gtk)         echo "python3-gi" ;;
        python-yaml)        echo "python3-yaml" ;;
        python-requests)    echo "python3-requests" ;;
        python-bs4)         echo "python3-bs4" ;;
        python-pil)         echo "python3-pil" ;;
        
        # GTK/GUI packages
        gtk3-dev)           echo "gir1.2-gtk-3.0" ;;
        vte-dev)            echo "gir1.2-vte-2.91" ;;
        gdkpixbuf-dev)      echo "gir1.2-gdkpixbuf-2.0" ;;
        
        # Build tools
        build-tools)        echo "build-essential" ;;
        pkg-config)         echo "pkg-config" ;;
        
        # Development libraries
        ssl-dev)            echo "libssl-dev" ;;
        readline-dev)       echo "libreadline-dev" ;;
        zlib-dev)           echo "zlib1g-dev" ;;
        yaml-dev)           echo "libyaml-dev" ;;
        ncurses-dev)        echo "libncurses5-dev" ;;
        ffi-dev)            echo "libffi-dev" ;;
        gdbm-dev)           echo "libgdbm-dev" ;;
        sqlite-dev)         echo "libsqlite3-0" ;;
        mysql-dev)          echo "libmysqlclient-dev" ;;
        postgres-dev)       echo "libpq-dev" ;;
        
        # System utilities
        locate)             echo "plocate" ;;
        apache-utils)       echo "apache2-utils" ;;
        find-alt)           echo "fd-find" ;;
        
        # Terminal apps (most are same on Ubuntu)
        fuzzy-finder)       echo "fzf" ;;
        grep-alt)           echo "ripgrep" ;;
        cat-alt)            echo "bat" ;;
        ls-alt)             echo "eza" ;;
        cd-alt)             echo "zoxide" ;;
        
        # Default: return unchanged
        *)                  echo "$generic_name" ;;
    esac
}

distro_setup_desktop() {
    # Ubuntu comes with GNOME by default, minimal setup needed
    distro_info "Ubuntu desktop environment detected"
    
    # Check if GNOME is installed
    if ! command -v gnome-shell &>/dev/null; then
        distro_warn "GNOME Shell not installed. Bentobox works best with GNOME."
        return 1
    fi
    
    distro_success "GNOME desktop ready"
    return 0
}

distro_get_pkg_manager() {
    echo "apt"
}

distro_get_pkg_format() {
    echo "deb"
}

# ============================================================================
# UBUNTU-SPECIFIC HELPERS
# ============================================================================

# Check if running on Pop!_OS
is_popos() {
    [[ "$BENTOBOX_DISTRO_ID" == "pop" ]]
}

# Check if running on Elementary OS
is_elementary() {
    [[ "$BENTOBOX_DISTRO_ID" == "elementary" ]]
}

# Check if running on Linux Mint
is_mint() {
    [[ "$BENTOBOX_DISTRO_ID" == "mint" ]]
}

# Check if running on KDE Neon
is_neon() {
    [[ "$BENTOBOX_DISTRO_ID" == "neon" ]]
}

