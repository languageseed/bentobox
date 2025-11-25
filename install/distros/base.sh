#!/bin/bash
# Base Distribution Plugin Interface
# All distribution plugins MUST implement these functions

# ============================================================================
# REQUIRED FUNCTIONS - Every plugin must implement these
# ============================================================================

# Verify distribution requirements
# Returns: 0 if OK, 1 if requirements not met
distro_verify() {
    echo "❌ distro_verify() not implemented in plugin"
    return 1
}

# Update package lists
distro_pkg_update() {
    echo "❌ distro_pkg_update() not implemented in plugin"
    return 1
}

# Upgrade all packages
distro_pkg_upgrade() {
    echo "❌ distro_pkg_upgrade() not implemented in plugin"
    return 1
}

# Install packages
# Usage: distro_pkg_install package1 package2 ...
distro_pkg_install() {
    echo "❌ distro_pkg_install() not implemented in plugin"
    return 1
}

# Remove packages
# Usage: distro_pkg_remove package1 package2 ...
distro_pkg_remove() {
    echo "❌ distro_pkg_remove() not implemented in plugin"
    return 1
}

# Check if package is installed
# Usage: distro_pkg_is_installed package_name
# Returns: 0 if installed, 1 if not
distro_pkg_is_installed() {
    echo "❌ distro_pkg_is_installed() not implemented in plugin"
    return 1
}

# Install a binary package from URL
# Usage: distro_install_binary URL
# Plugin should handle .deb, .rpm, or other formats
distro_install_binary() {
    local url="$1"
    echo "❌ distro_install_binary() not implemented in plugin"
    return 1
}

# Add external repository
# Usage: distro_add_repo TYPE NAME
# TYPE: ppa, copr, aur, custom, etc.
# NAME: repository identifier
distro_add_repo() {
    local type="$1"
    local name="$2"
    echo "❌ distro_add_repo() not implemented in plugin"
    return 1
}

# Map generic package name to distro-specific name
# Usage: distro_map_package generic_name
# Returns: distro-specific package name
distro_map_package() {
    local generic_name="$1"
    # Default: return unchanged
    echo "$generic_name"
}

# ============================================================================
# OPTIONAL FUNCTIONS - Plugins can override these
# ============================================================================

# Setup desktop environment (GNOME, KDE, etc.)
distro_setup_desktop() {
    echo "ℹ️  Desktop setup not needed for this distribution"
    return 0
}

# Install desktop-specific packages
distro_install_desktop_app() {
    local app_name="$1"
    echo "⚠️  Desktop app installation not customized: $app_name"
    # Fallback to generic installation
    return 1
}

# Get package manager command
distro_get_pkg_manager() {
    echo "unknown"
}

# Get package format (.deb, .rpm, etc.)
distro_get_pkg_format() {
    echo "unknown"
}

# ============================================================================
# HELPER FUNCTIONS - Available to all plugins
# ============================================================================

# Download file with progress
distro_download() {
    local url="$1"
    local output="$2"
    
    if command -v wget &>/dev/null; then
        wget -q --show-progress -O "$output" "$url"
    elif command -v curl &>/dev/null; then
        curl -L --progress-bar -o "$output" "$url"
    else
        echo "❌ Neither wget nor curl available"
        return 1
    fi
}

# Print error and exit
distro_error() {
    echo "❌ $*" >&2
    return 1
}

# Print warning
distro_warn() {
    echo "⚠️  $*" >&2
}

# Print info
distro_info() {
    echo "ℹ️  $*"
}

# Print success
distro_success() {
    echo "✓ $*"
}

