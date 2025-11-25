#!/bin/bash
# Distribution Manager - Main abstraction layer for Bentobox
# Provides a unified interface for package management across distributions

# Prevent double-loading
if [ -n "$BENTOBOX_DISTRO_MANAGER_LOADED" ]; then
    return 0
fi
export BENTOBOX_DISTRO_MANAGER_LOADED=1

# Get the library directory
BENTOBOX_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BENTOBOX_DISTROS_DIR="$(cd "$BENTOBOX_LIB_DIR/../distros" && pwd)"

# ============================================================================
# DISTRIBUTION DETECTION
# ============================================================================

detect_distribution() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        export BENTOBOX_DISTRO_ID="$ID"
        export BENTOBOX_DISTRO_VERSION="$VERSION_ID"
        export BENTOBOX_DISTRO_NAME="$PRETTY_NAME"
        export BENTOBOX_DISTRO_LIKE="$ID_LIKE"
        
        # Normalize ID (handle derivatives)
        case "$ID" in
            ubuntu|pop|elementary|mint|neon)
                export BENTOBOX_DISTRO_FAMILY="ubuntu"
                export BENTOBOX_DISTRO_PLUGIN="ubuntu"
                ;;
            debian|raspbian)
                export BENTOBOX_DISTRO_FAMILY="debian"
                export BENTOBOX_DISTRO_PLUGIN="debian"
                ;;
            fedora)
                export BENTOBOX_DISTRO_FAMILY="fedora"
                export BENTOBOX_DISTRO_PLUGIN="fedora"
                ;;
            arch|manjaro|endeavouros)
                export BENTOBOX_DISTRO_FAMILY="arch"
                export BENTOBOX_DISTRO_PLUGIN="arch"
                ;;
            rhel|rocky|almalinux|centos)
                export BENTOBOX_DISTRO_FAMILY="rhel"
                export BENTOBOX_DISTRO_PLUGIN="rocky"
                ;;
            *)
                # Try to detect from ID_LIKE
                if [[ "$ID_LIKE" =~ "ubuntu" ]]; then
                    export BENTOBOX_DISTRO_FAMILY="ubuntu"
                    export BENTOBOX_DISTRO_PLUGIN="ubuntu"
                elif [[ "$ID_LIKE" =~ "debian" ]]; then
                    export BENTOBOX_DISTRO_FAMILY="debian"
                    export BENTOBOX_DISTRO_PLUGIN="debian"
                else
                    export BENTOBOX_DISTRO_FAMILY="unknown"
                    export BENTOBOX_DISTRO_PLUGIN=""
                fi
                ;;
        esac
    else
        echo "❌ Cannot detect distribution (/etc/os-release not found)"
        export BENTOBOX_DISTRO_FAMILY="unknown"
        export BENTOBOX_DISTRO_PLUGIN=""
        return 1
    fi
}

# ============================================================================
# PLUGIN LOADING
# ============================================================================

load_distribution_plugin() {
    local plugin="$BENTOBOX_DISTRO_PLUGIN"
    
    if [ -z "$plugin" ]; then
        echo "❌ No distribution plugin available"
        return 1
    fi
    
    local plugin_file="$BENTOBOX_DISTROS_DIR/${plugin}.sh"
    
    if [ ! -f "$plugin_file" ]; then
        echo "❌ Distribution plugin not found: $plugin_file"
        echo "   Detected: $BENTOBOX_DISTRO_NAME"
        echo "   Plugin: $plugin"
        echo ""
        echo "💡 This distribution is not yet supported."
        echo "   Supported distributions:"
        echo "   - Ubuntu 24.04+"
        echo "   - Debian 12+"
        return 1
    fi
    
    # Source the plugin
    . "$plugin_file"
    
    # Verify plugin loaded correctly
    if ! command -v distro_verify &>/dev/null; then
        echo "❌ Plugin failed to load: $plugin"
        return 1
    fi
    
    # Run plugin verification
    if ! distro_verify; then
        echo "❌ Distribution verification failed"
        return 1
    fi
    
    return 0
}

# ============================================================================
# INITIALIZE
# ============================================================================

# Detect distribution
if ! detect_distribution; then
    echo "⚠️  Running in fallback mode (limited functionality)"
fi

# Load appropriate plugin
if [ -n "$BENTOBOX_DISTRO_PLUGIN" ]; then
    if load_distribution_plugin; then
        echo "✓ Loaded distribution plugin: $BENTOBOX_DISTRO_PLUGIN ($BENTOBOX_DISTRO_NAME)"
    else
        echo "⚠️  Failed to load distribution plugin"
    fi
fi

# ============================================================================
# PACKAGE NAME MAPPING
# ============================================================================

# Map generic package name to distro-specific name
# This allows scripts to use generic names like "python-gtk" instead of
# "python3-gi" (Ubuntu) or "python-gobject" (Arch)
pkg_map_name() {
    local generic_name="$1"
    
    # If plugin has custom mapping, use it
    if command -v distro_map_package &>/dev/null; then
        local mapped=$(distro_map_package "$generic_name")
        if [ -n "$mapped" ]; then
            echo "$mapped"
            return 0
        fi
    fi
    
    # Otherwise return generic name (assume it's correct)
    echo "$generic_name"
}

# ============================================================================
# CONVENIENCE WRAPPER FUNCTIONS
# ============================================================================

# These are convenience wrappers that scripts can use
# They call the appropriate distro_* function from the loaded plugin

bentobox_pkg_update() {
    if command -v distro_pkg_update &>/dev/null; then
        distro_pkg_update "$@"
    else
        echo "❌ Package update not available (no plugin loaded)"
        return 1
    fi
}

bentobox_pkg_upgrade() {
    if command -v distro_pkg_upgrade &>/dev/null; then
        distro_pkg_upgrade "$@"
    else
        echo "❌ Package upgrade not available (no plugin loaded)"
        return 1
    fi
}

bentobox_pkg_install() {
    if command -v distro_pkg_install &>/dev/null; then
        distro_pkg_install "$@"
    else
        echo "❌ Package installation not available (no plugin loaded)"
        return 1
    fi
}

bentobox_pkg_remove() {
    if command -v distro_pkg_remove &>/dev/null; then
        distro_pkg_remove "$@"
    else
        echo "❌ Package removal not available (no plugin loaded)"
        return 1
    fi
}

bentobox_pkg_is_installed() {
    if command -v distro_pkg_is_installed &>/dev/null; then
        distro_pkg_is_installed "$@"
    else
        echo "❌ Package check not available (no plugin loaded)"
        return 1
    fi
}

bentobox_install_binary() {
    if command -v distro_install_binary &>/dev/null; then
        distro_install_binary "$@"
    else
        echo "❌ Binary installation not available (no plugin loaded)"
        return 1
    fi
}

bentobox_add_repo() {
    if command -v distro_add_repo &>/dev/null; then
        distro_add_repo "$@"
    else
        echo "❌ Repository management not available (no plugin loaded)"
        return 1
    fi
}

