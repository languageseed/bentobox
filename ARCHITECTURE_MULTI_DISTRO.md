# Multi-Distribution Architecture Design

**Goal:** Create a flexible architecture that supports Ubuntu/Debian NOW, but can easily expand to Arch/Fedora/Rocky LATER without major refactoring.

**Philosophy:** "Design for tomorrow, build for today"

---

## Design Principles

1. **Abstraction Over Implementation** - Hide distro-specific details behind interfaces
2. **Gradual Migration** - Old scripts continue to work while new ones use the abstraction
3. **Plugin Architecture** - Each distro is a "plugin" that implements the same interface
4. **Sensible Defaults** - Ubuntu/Debian work perfectly, others gracefully degrade
5. **Zero Breaking Changes** - Existing installations continue to work

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    Bentobox Core                             │
│                  (orchestrator.py)                           │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│              Distribution Manager                            │
│           (install/lib/distro-manager.sh)                    │
│                                                              │
│  • Detects current distribution                             │
│  • Loads appropriate plugin                                 │
│  • Exports unified interface                                │
└────────────────────────┬────────────────────────────────────┘
                         │
        ┌────────────────┼────────────────┬──────────────────┐
        ▼                ▼                ▼                  ▼
┌──────────────┐ ┌──────────────┐ ┌──────────────┐ ┌──────────────┐
│   Ubuntu     │ │   Debian     │ │    Fedora    │ │     Arch     │
│   Plugin     │ │   Plugin     │ │   Plugin     │ │    Plugin    │
│              │ │              │ │  (future)    │ │   (future)   │
│ • pkg_*()    │ │ • pkg_*()    │ │              │ │              │
│ • repo_*()   │ │ • repo_*()   │ │              │ │              │
│ • desktop_*()│ │ • desktop_*()│ │              │ │              │
└──────────────┘ └──────────────┘ └──────────────┘ └──────────────┘
```

---

## Directory Structure

```
bentobox/
├── install/
│   ├── lib/                           # NEW: Core libraries
│   │   ├── distro-manager.sh          # Main abstraction layer
│   │   ├── package-mapping.yaml       # Package name mappings
│   │   └── utils.sh                   # Shared utilities
│   │
│   ├── distros/                       # NEW: Distribution plugins
│   │   ├── ubuntu.sh                  # Ubuntu-specific implementation
│   │   ├── debian.sh                  # Debian-specific implementation
│   │   ├── fedora.sh                  # Fedora (future)
│   │   ├── arch.sh                    # Arch (future)
│   │   └── base.sh                    # Base interface (all must implement)
│   │
│   ├── terminal/                      # Existing terminal installers
│   │   ├── docker.sh                  # MIGRATE: Use new abstraction
│   │   ├── app-neovim.sh             # MIGRATE: Use new abstraction
│   │   └── ...
│   │
│   ├── desktop/                       # Existing desktop installers
│   │   ├── app-chrome.sh             # MIGRATE: Use new abstraction
│   │   └── ...
│   │
│   ├── check-version.sh              # UPDATE: Use distro detection
│   ├── orchestrator.py               # UPDATE: Load distro plugin
│   └── install.sh                    # No change needed
│
├── docs/
│   └── architecture/
│       ├── DISTRO_PLUGIN_SPEC.md     # NEW: Plugin interface spec
│       └── MIGRATION_GUIDE.md        # NEW: How to migrate scripts
│
└── tests/                            # NEW: Testing framework
    ├── test-ubuntu.sh
    ├── test-debian.sh
    └── ...
```

---

## Implementation Plan

### Phase 1: Foundation (Week 1 - 8 hours)
Create the abstraction layer WITHOUT breaking existing functionality.

**Deliverables:**
1. `install/lib/distro-manager.sh` - Main abstraction
2. `install/distros/base.sh` - Interface specification
3. `install/distros/ubuntu.sh` - Ubuntu implementation
4. `install/distros/debian.sh` - Debian implementation
5. `install/lib/package-mapping.yaml` - Package mappings

**Status:** Existing scripts continue to work as-is

---

### Phase 2: Core Migration (Week 2 - 12 hours)
Migrate critical infrastructure scripts to use abstraction.

**Priority Scripts (10-15 files):**
1. `install/check-version.sh` - Distro detection
2. `install.sh` - Python installation
3. `install-gui.sh` - GTK dependencies
4. `install/terminal.sh` - Base packages
5. `install/terminal/docker.sh` - Docker
6. `install/terminal/libraries.sh` - Dev libraries
7. `install/terminal/apps-terminal.sh` - Terminal apps
8. `install/desktop/a-flatpak.sh` - Flatpak setup
9. `install/desktop/app-chrome.sh` - Chrome
10. `install/desktop/app-vscode.sh` - VS Code

**Status:** Core functionality works on Ubuntu AND Debian

---

### Phase 3: Gradual Migration (Ongoing - 2-3 hours per sprint)
Migrate remaining scripts over time as they're touched.

**Strategy:**
- When fixing a bug in a script, migrate it to new abstraction
- When adding a new feature, use new abstraction
- No need to migrate everything at once

**Status:** Mixed (some old, some new - both work)

---

### Phase 4: Future Expansion (When needed)
Add new distribution plugins as demand arises.

**To add Fedora support:**
1. Create `install/distros/fedora.sh` (4 hours)
2. Add Fedora package mappings (2 hours)
3. Test on Fedora (4 hours)
4. Document Fedora-specific quirks (1 hour)

**Total for new distro:** ~10-15 hours per distribution

---

## Technical Design

### 1. Distribution Manager (`install/lib/distro-manager.sh`)

This is the main abstraction layer that all scripts will source.

```bash
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
            ubuntu|pop|elementary|mint)
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
# COMPATIBILITY LAYER (for old scripts)
# ============================================================================

# These functions allow old scripts to continue working without modification
# New scripts should use the distro_* functions directly

# Legacy function: acts like apt but uses current distro's package manager
apt() {
    if command -v distro_pkg &>/dev/null; then
        distro_pkg "$@"
    else
        # Fallback to real apt if no plugin loaded
        command apt "$@"
    fi
}

# Note: This is experimental and may not cover all use cases
# Better approach: explicitly update scripts to use distro_* functions
```

---

### 2. Base Plugin Interface (`install/distros/base.sh`)

This defines the contract that ALL distribution plugins must implement.

```bash
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
# TYPE: ppa, copr, aur, custom
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
```

---

### 3. Ubuntu Plugin (`install/distros/ubuntu.sh`)

Full implementation for Ubuntu (and derivatives like Pop!_OS, Elementary, etc.)

```bash
#!/bin/bash
# Ubuntu Distribution Plugin
# Supports: Ubuntu 24.04+, Pop!_OS, Elementary OS, Linux Mint

# Source base interface
source "$BENTOBOX_DISTROS_DIR/base.sh"

# ============================================================================
# UBUNTU-SPECIFIC IMPLEMENTATION
# ============================================================================

distro_verify() {
    # Check Ubuntu version
    if [[ "$BENTOBOX_DISTRO_ID" == "ubuntu" ]]; then
        local major_version="${BENTOBOX_DISTRO_VERSION%%.*}"
        if [ "$major_version" -lt 24 ]; then
            distro_error "Ubuntu 24.04+ required (detected: $BENTOBOX_DISTRO_VERSION)"
            return 1
        fi
    fi
    
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
    sudo apt install -y "${packages[@]}"
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
        distro_download "$url" "$temp_deb"
        
        distro_info "Installing .deb package..."
        sudo dpkg -i "$temp_deb"
        
        # Fix dependencies if needed
        sudo apt-get install -f -y
        
        rm "$temp_deb"
        return 0
    else
        distro_error "Ubuntu plugin can only install .deb packages"
        return 1
    fi
}

distro_add_repo() {
    local type="$1"
    local name="$2"
    
    case "$type" in
        ppa)
            sudo add-apt-repository -y "ppa:$name"
            sudo apt update
            ;;
        custom)
            # For custom repos, name should be full repo line
            echo "$name" | sudo tee "/etc/apt/sources.list.d/bentobox-$type.list" >/dev/null
            sudo apt update
            ;;
        *)
            distro_error "Unknown repository type: $type"
            return 1
            ;;
    esac
}

distro_map_package() {
    local generic_name="$1"
    
    # Ubuntu-specific package name mappings
    case "$generic_name" in
        python-gtk)         echo "python3-gi" ;;
        python-yaml)        echo "python3-yaml" ;;
        python-requests)    echo "python3-requests" ;;
        gtk3-dev)           echo "gir1.2-gtk-3.0" ;;
        vte-dev)            echo "gir1.2-vte-2.91" ;;
        build-tools)        echo "build-essential" ;;
        ssl-dev)            echo "libssl-dev" ;;
        readline-dev)       echo "libreadline-dev" ;;
        *)                  echo "$generic_name" ;;  # Return unchanged
    esac
}

distro_setup_desktop() {
    # Ubuntu comes with GNOME by default, minimal setup needed
    distro_info "Ubuntu desktop environment detected"
    
    # Ensure GNOME packages are installed
    if ! distro_pkg_is_installed "gnome-shell"; then
        distro_warn "GNOME Shell not installed. Bentobox works best with GNOME."
        return 1
    fi
    
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
```

---

### 4. Debian Plugin (`install/distros/debian.sh`)

```bash
#!/bin/bash
# Debian Distribution Plugin
# Supports: Debian 12 (Bookworm)+, Raspbian

# Source Ubuntu plugin as base (Debian is very similar)
source "$BENTOBOX_DISTROS_DIR/ubuntu.sh"

# ============================================================================
# DEBIAN-SPECIFIC OVERRIDES
# ============================================================================

distro_verify() {
    # Check Debian version
    if [[ "$BENTOBOX_DISTRO_ID" == "debian" ]] || [[ "$BENTOBOX_DISTRO_ID" == "raspbian" ]]; then
        local major_version="${BENTOBOX_DISTRO_VERSION%%.*}"
        if [ "$major_version" -lt 12 ]; then
            distro_error "Debian 12 (Bookworm)+ required (detected: $BENTOBOX_DISTRO_VERSION)"
            return 1
        fi
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
            return 1
            ;;
        debian-testing)
            # Enable Debian Testing for specific packages
            echo "deb http://deb.debian.org/debian testing main" | \
                sudo tee /etc/apt/sources.list.d/bentobox-testing.list >/dev/null
            sudo apt update
            ;;
        debian-backports)
            # Enable Debian Backports
            echo "deb http://deb.debian.org/debian $(lsb_release -sc)-backports main" | \
                sudo tee /etc/apt/sources.list.d/bentobox-backports.list >/dev/null
            sudo apt update
            ;;
        custom)
            # Call parent implementation
            source "$BENTOBOX_DISTROS_DIR/ubuntu.sh"
            distro_add_repo custom "$name"
            ;;
        *)
            distro_error "Unknown repository type: $type"
            return 1
            ;;
    esac
}

distro_setup_desktop() {
    distro_info "Debian desktop environment detected"
    
    # Debian can use various desktop environments
    if command -v gnome-shell &>/dev/null; then
        distro_info "GNOME desktop detected"
        return 0
    elif command -v plasmashell &>/dev/null; then
        distro_warn "KDE Plasma detected. Some GNOME-specific features may not work."
        return 0
    elif command -v xfce4-session &>/dev/null; then
        distro_warn "XFCE detected. Some GNOME-specific features may not work."
        return 0
    else
        distro_warn "Could not detect desktop environment"
        return 1
    fi
}
```

---

### 5. Package Mapping System (`install/lib/package-mapping.yaml`)

```yaml
# Package name mappings across distributions
# Format:
#   generic_name:
#     ubuntu: package_name
#     debian: package_name
#     fedora: package_name
#     arch: package_name

# Python packages
python-gtk:
  ubuntu: python3-gi
  debian: python3-gi
  fedora: python3-gobject
  arch: python-gobject

python-yaml:
  ubuntu: python3-yaml
  debian: python3-yaml
  fedora: python3-pyyaml
  arch: python-yaml

python-requests:
  ubuntu: python3-requests
  debian: python3-requests
  fedora: python3-requests
  arch: python-requests

python-pil:
  ubuntu: python3-pil
  debian: python3-pil
  fedora: python3-pillow
  arch: python-pillow

# GTK/GUI packages
gtk3-dev:
  ubuntu: gir1.2-gtk-3.0
  debian: gir1.2-gtk-3.0
  fedora: gtk3-devel
  arch: gtk3

vte-dev:
  ubuntu: gir1.2-vte-2.91
  debian: gir1.2-vte-2.91
  fedora: vte291
  arch: vte3

# Build tools
build-tools:
  ubuntu: build-essential
  debian: build-essential
  fedora: "@development-tools"
  arch: base-devel

# Development libraries
ssl-dev:
  ubuntu: libssl-dev
  debian: libssl-dev
  fedora: openssl-devel
  arch: openssl

readline-dev:
  ubuntu: libreadline-dev
  debian: libreadline-dev
  fedora: readline-devel
  arch: readline

zlib-dev:
  ubuntu: zlib1g-dev
  debian: zlib1g-dev
  fedora: zlib-devel
  arch: zlib

yaml-dev:
  ubuntu: libyaml-dev
  debian: libyaml-dev
  fedora: libyaml-devel
  arch: libyaml

ncurses-dev:
  ubuntu: libncurses5-dev
  debian: libncurses5-dev
  fedora: ncurses-devel
  arch: ncurses

ffi-dev:
  ubuntu: libffi-dev
  debian: libffi-dev
  fedora: libffi-devel
  arch: libffi

# Terminal applications
terminal-multiplexer:
  ubuntu: tmux
  debian: tmux
  fedora: tmux
  arch: tmux

fuzzy-finder:
  ubuntu: fzf
  debian: fzf
  fedora: fzf
  arch: fzf

grep-alternative:
  ubuntu: ripgrep
  debian: ripgrep
  fedora: ripgrep
  arch: ripgrep

cat-alternative:
  ubuntu: bat
  debian: bat
  fedora: bat
  arch: bat

ls-alternative:
  ubuntu: eza
  debian: eza
  fedora: eza
  arch: eza

cd-alternative:
  ubuntu: zoxide
  debian: zoxide
  fedora: zoxide
  arch: zoxide

# System utilities
locate:
  ubuntu: plocate
  debian: plocate
  fedora: mlocate
  arch: plocate

apache-utils:
  ubuntu: apache2-utils
  debian: apache2-utils
  fedora: httpd-tools
  arch: apache

find-alternative:
  ubuntu: fd-find
  debian: fd-find
  fedora: fd-find
  arch: fd

# Container & virtualization
docker:
  ubuntu: docker-ce
  debian: docker-ce
  fedora: docker-ce
  arch: docker

docker-compose:
  ubuntu: docker-compose-plugin
  debian: docker-compose-plugin
  fedora: docker-compose-plugin
  arch: docker-compose
```

---

## Migration Guide for Existing Scripts

### Before (Old Style):

```bash
#!/bin/bash
# install/terminal/app-btop.sh

sudo apt update
sudo apt install -y btop
```

### After (New Style):

```bash
#!/bin/bash
# install/terminal/app-btop.sh

# Source distribution manager
source "$OMAKUB_PATH/install/lib/distro-manager.sh"

# Check if already installed
if distro_pkg_is_installed btop; then
    echo "✓ btop already installed"
    exit 0
fi

# Install using distribution's package manager
distro_pkg_install btop
```

### Complex Example (Docker):

**Before:**
```bash
#!/bin/bash
# install/terminal/docker.sh

# Add the official Docker repo
sudo install -m 0755 -d /etc/apt/keyrings
sudo wget -qO /etc/apt/keyrings/docker.asc https://download.docker.com/linux/ubuntu/gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
sudo tee /etc/apt/sources.list.d/docker.list >/dev/null

sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo usermod -aG docker ${USER}
```

**After:**
```bash
#!/bin/bash
# install/terminal/docker.sh

# Source distribution manager
source "$OMAKUB_PATH/install/lib/distro-manager.sh"

# Check if already installed
if command -v docker &>/dev/null; then
    echo "✓ Docker already installed"
    exit 0
fi

# Distribution-specific Docker installation
case "$BENTOBOX_DISTRO_FAMILY" in
    ubuntu|debian)
        # Add Docker repository
        sudo install -m 0755 -d /etc/apt/keyrings
        sudo wget -qO /etc/apt/keyrings/docker.asc \
            "https://download.docker.com/linux/$BENTOBOX_DISTRO_ID/gpg"
        
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
https://download.docker.com/linux/$BENTOBOX_DISTRO_ID \
$(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
            sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
        
        distro_pkg_update
        distro_pkg_install docker-ce docker-ce-cli containerd.io \
            docker-buildx-plugin docker-compose-plugin
        ;;
    
    fedora)
        # Fedora-specific (future)
        sudo dnf install -y docker-ce docker-ce-cli containerd.io
        ;;
    
    arch)
        # Arch-specific (future)
        distro_pkg_install docker docker-compose
        ;;
    
    *)
        echo "❌ Docker installation not yet supported on $BENTOBOX_DISTRO_NAME"
        exit 1
        ;;
esac

# Common post-installation
sudo usermod -aG docker ${USER}
echo '{"log-driver":"json-file","log-opts":{"max-size":"10m","max-file":"5"}}' | \
    sudo tee /etc/docker/daemon.json >/dev/null
```

---

## Complexity Assessment

### Implementation Complexity: ⭐⭐⭐ (Medium)

**Phase 1 (Foundation):**
- **Time:** 8-10 hours
- **Files:** 5 new files
- **Complexity:** Medium (bash scripting, interface design)
- **Risk:** Low (no changes to existing functionality)

**Phase 2 (Core Migration):**
- **Time:** 12-15 hours
- **Files:** 10-15 modifications
- **Complexity:** Medium (refactoring existing scripts)
- **Risk:** Medium (testing required to ensure no regressions)

**Phase 3 (Gradual Migration):**
- **Time:** 2-3 hours per sprint (ongoing)
- **Files:** 5-10 per sprint
- **Complexity:** Low (following established patterns)
- **Risk:** Low (incremental changes)

**Total Initial Investment:** 20-25 hours for Ubuntu + Debian support

---

### Future Expansion Complexity: ⭐⭐ (Low-Medium)

**Adding Fedora (with architecture in place):**
- Create `fedora.sh` plugin: 4 hours
- Add package mappings: 2 hours
- Test and debug: 4 hours
- **Total:** 10 hours

**Adding Arch (with architecture in place):**
- Create `arch.sh` plugin: 6 hours
- Add package mappings: 3 hours
- AUR helper integration: 4 hours
- Test and debug: 6 hours
- **Total:** 19 hours

**Compared to WITHOUT architecture:**
- Fedora: 30-40 hours (3-4x slower)
- Arch: 40-60 hours (2-3x slower)

**ROI:** Architecture pays for itself after adding 2 distributions

---

## Testing Strategy

### 1. Unit Tests for Abstraction Layer

```bash
#!/bin/bash
# tests/test-distro-manager.sh

source install/lib/distro-manager.sh

# Test distro detection
test_detection() {
    assert_not_empty "$BENTOBOX_DISTRO_ID"
    assert_not_empty "$BENTOBOX_DISTRO_FAMILY"
}

# Test package installation
test_package_install() {
    if distro_pkg_install curl; then
        assert_command_exists curl
    fi
}

# Test package mapping
test_package_mapping() {
    local mapped=$(pkg_map_name "python-gtk")
    assert_not_equals "$mapped" "python-gtk"  # Should be mapped
}
```

### 2. Integration Tests per Distribution

```bash
#!/bin/bash
# tests/test-ubuntu.sh

# Full installation test on Ubuntu
test_full_install() {
    # Run installation
    bash install.sh --test-mode
    
    # Verify core packages installed
    assert_command_exists docker
    assert_command_exists nvim
    assert_command_exists fzf
}
```

### 3. CI/CD Matrix

```yaml
# .github/workflows/test.yml
name: Multi-Distro Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        distro:
          - ubuntu:24.04
          - ubuntu:24.10
          - debian:12
          - debian:13
          # Future:
          # - fedora:40
          # - archlinux:latest
    
    container:
      image: ${{ matrix.distro }}
    
    steps:
      - uses: actions/checkout@v3
      - name: Run tests
        run: bash tests/run-tests.sh
```

---

## Benefits of This Architecture

### 1. ✅ Clean Separation of Concerns
- Core logic separate from distro-specific details
- Easy to understand and maintain
- Clear ownership (distro maintainers can own their plugin)

### 2. ✅ Backward Compatible
- Existing scripts continue to work
- Gradual migration (no "big bang" rewrite)
- Can mix old and new styles

### 3. ✅ Future-Proof
- Adding new distros is straightforward (10-20 hours each)
- Plugin architecture is extensible
- Package mappings centralized

### 4. ✅ Testable
- Each plugin can be tested independently
- Mock different distributions for testing
- CI/CD friendly

### 5. ✅ Maintainable
- Changes to one distro don't affect others
- Bug fixes can be distro-specific
- Clear documentation of requirements

### 6. ✅ Community-Friendly
- Contributors can add their favorite distro
- Plugin specification is clear
- Lower barrier to contribution

---

## Documentation Requirements

### 1. Plugin Developer Guide (`docs/architecture/DISTRO_PLUGIN_SPEC.md`)
- How to create a new plugin
- Required vs optional functions
- Testing checklist
- Examples

### 2. Migration Guide (`docs/architecture/MIGRATION_GUIDE.md`)
- How to update old scripts
- Common patterns
- Before/after examples
- Troubleshooting

### 3. Architecture Overview (`docs/architecture/OVERVIEW.md`)
- High-level design
- Decision rationale
- Flow diagrams
- Future roadmap

---

## Recommendation

### ✅ **YES - Implement This Architecture**

**Reasoning:**
1. **Low initial cost** (20-25 hours) for Ubuntu + Debian
2. **High future value** - Makes adding distros 2-3x faster
3. **Clean design** - Improves code quality overall
4. **Backward compatible** - No breaking changes
5. **Gradual migration** - Can implement incrementally

**Timeline:**
- **Week 1:** Build foundation (8-10 hours)
- **Week 2:** Migrate core scripts (12-15 hours)
- **Ongoing:** Migrate remaining scripts as touched (2-3 hours/sprint)

**ROI:**
- Pays for itself after adding 2nd distribution
- Makes Bentobox more professional
- Attracts more contributors
- Future-proofs the project

### 🎯 **Start with Phase 1 (Foundation)**

Build the abstraction layer without migrating any scripts yet. This:
- ✅ Establishes the pattern
- ✅ Can be tested in isolation
- ✅ Doesn't risk breaking existing functionality
- ✅ Demonstrates the approach

Then decide whether to continue based on:
- Community interest in other distros
- Available development time
- Code quality improvements observed

---

## Next Steps

Would you like me to:

1. **Implement Phase 1** - Create the foundation files (distro-manager.sh, base.sh, ubuntu.sh, debian.sh)?

2. **Start Phase 2** - Migrate the top 5 critical scripts as proof of concept?

3. **Create documentation** - Write the plugin spec and migration guide?

4. **Something else** - Different approach or focus area?

Let me know and I'll proceed!

