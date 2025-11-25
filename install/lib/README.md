# Bentobox Distribution Abstraction Layer

This directory contains the distribution abstraction layer that allows Bentobox to support multiple Linux distributions.

## Overview

The abstraction layer provides a unified interface for package management, allowing installation scripts to work across different distributions without modification.

## Architecture

```
┌─────────────────────────────────────────┐
│        Installation Scripts              │
│  (terminal/*, desktop/*, optional/*)     │
└────────────────┬────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────┐
│      Distribution Manager               │
│    (lib/distro-manager.sh)              │
│                                         │
│  • Detects current distribution         │
│  • Loads appropriate plugin             │
│  • Provides unified functions           │
└────────────────┬────────────────────────┘
                 │
        ┌────────┴────────┬───────────┐
        ▼                 ▼           ▼
┌──────────────┐  ┌──────────────┐  ┌──────────────┐
│   Ubuntu     │  │   Debian     │  │   Fedora     │
│   Plugin     │  │   Plugin     │  │   Plugin     │
│              │  │              │  │   (future)   │
└──────────────┘  └──────────────┘  └──────────────┘
```

## Directory Structure

```
install/
├── lib/                          # Core libraries
│   ├── distro-manager.sh         # Main abstraction layer
│   ├── package-mapping.yaml      # Package name mappings
│   └── utils.sh                  # Utility functions
│
└── distros/                      # Distribution plugins
    ├── base.sh                   # Base interface (all plugins implement)
    ├── ubuntu.sh                 # Ubuntu implementation ✅
    ├── debian.sh                 # Debian implementation ✅
    ├── fedora.sh                 # Fedora (future)
    └── arch.sh                   # Arch (future)
```

## Usage

### In Installation Scripts

Instead of directly calling `apt`, source the distribution manager and use the abstraction functions:

**Old way (Ubuntu-only):**
```bash
#!/bin/bash
sudo apt update
sudo apt install -y curl git
```

**New way (Multi-distro):**
```bash
#!/bin/bash
source "$OMAKUB_PATH/install/lib/distro-manager.sh"

distro_pkg_update
distro_pkg_install curl git
```

### Available Functions

#### Package Management
- `distro_pkg_update` - Update package lists
- `distro_pkg_upgrade` - Upgrade all packages
- `distro_pkg_install <packages...>` - Install packages
- `distro_pkg_remove <packages...>` - Remove packages
- `distro_pkg_is_installed <package>` - Check if package is installed

#### Repository Management
- `distro_add_repo <type> <name>` - Add external repository
  - Types: `ppa`, `copr`, `custom`, `debian-testing`, `debian-backports`

#### Binary Installation
- `distro_install_binary <url>` - Install from .deb, .rpm, etc.

#### Package Mapping
- `distro_map_package <generic_name>` - Map generic to distro-specific name

#### Desktop Environment
- `distro_setup_desktop` - Setup/verify desktop environment

#### Information
- `distro_get_pkg_manager` - Get package manager name (apt, dnf, pacman)
- `distro_get_pkg_format` - Get package format (deb, rpm, pkg)

### Environment Variables

After loading the distribution manager, these variables are available:

- `$BENTOBOX_DISTRO_ID` - Distribution ID (ubuntu, debian, fedora, arch)
- `$BENTOBOX_DISTRO_VERSION` - Version number
- `$BENTOBOX_DISTRO_NAME` - Pretty name (e.g., "Ubuntu 24.04")
- `$BENTOBOX_DISTRO_FAMILY` - Family (ubuntu, debian, fedora, arch, rhel)
- `$BENTOBOX_DISTRO_PLUGIN` - Loaded plugin name

## Package Name Mapping

Scripts can use generic package names that get automatically mapped to distro-specific names:

```bash
# Instead of:
sudo apt install -y python3-gi libssl-dev

# Use:
distro_pkg_install python-gtk ssl-dev

# Automatically maps to:
#   Ubuntu: python3-gi libssl-dev
#   Debian: python3-gi libssl-dev
#   Fedora: python3-gobject openssl-devel
#   Arch:   python-gobject openssl
```

See `lib/package-mapping.yaml` for all available mappings.

## Currently Supported Distributions

### ✅ Ubuntu 24.04+
- Full support
- Includes: Ubuntu, Pop!_OS, Elementary OS, Linux Mint, KDE Neon
- Package manager: apt
- Package format: .deb

### ✅ Debian 12 (Bookworm)+
- Full support
- Includes: Debian, Raspbian
- Package manager: apt
- Package format: .deb
- Note: PPAs not supported, use Debian Testing or Backports

### 🚧 Fedora (Future)
- Planned support
- Package manager: dnf
- Package format: .rpm

### 🚧 Arch Linux (Future)
- Planned support
- Package manager: pacman
- Package format: .pkg.tar.zst

## Creating a New Distribution Plugin

See `../docs/architecture/DISTRO_PLUGIN_GUIDE.md` for detailed instructions.

Quick overview:

1. Create `distros/<distro>.sh`
2. Source `distros/base.sh`
3. Implement required functions:
   - `distro_verify()`
   - `distro_pkg_update()`
   - `distro_pkg_upgrade()`
   - `distro_pkg_install()`
   - `distro_pkg_remove()`
   - `distro_pkg_is_installed()`
   - `distro_install_binary()`
   - `distro_add_repo()`
   - `distro_map_package()`
4. Test on target distribution
5. Submit PR

## Migration Guide

### Migrating Existing Scripts

1. **Add source line at top:**
   ```bash
   source "$OMAKUB_PATH/install/lib/distro-manager.sh"
   ```

2. **Replace apt commands:**
   - `sudo apt update` → `distro_pkg_update`
   - `sudo apt install -y PKG` → `distro_pkg_install PKG`
   - `dpkg -l | grep PKG` → `distro_pkg_is_installed PKG`

3. **Use generic package names:**
   - Check `lib/package-mapping.yaml` for available mappings
   - Submit PR to add new mappings as needed

4. **Test on Ubuntu and Debian:**
   - Verify script still works correctly
   - Check that error messages are helpful

### Example Migration

**Before:**
```bash
#!/bin/bash
# install/terminal/docker.sh

sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io
sudo usermod -aG docker ${USER}
```

**After:**
```bash
#!/bin/bash
# install/terminal/docker.sh

source "$OMAKUB_PATH/install/lib/distro-manager.sh"

distro_pkg_update
distro_pkg_install docker docker-compose
sudo usermod -aG docker ${USER}
```

## Testing

### Unit Tests
```bash
# Test distribution detection
bash tests/test-distro-detection.sh

# Test package mapping
bash tests/test-package-mapping.sh
```

### Integration Tests
```bash
# Test on Ubuntu
bash tests/test-ubuntu-full.sh

# Test on Debian
bash tests/test-debian-full.sh
```

## Backward Compatibility

The abstraction layer is designed to be **100% backward compatible**:

- Old scripts without `source distro-manager.sh` continue to work on Ubuntu
- Can mix old and new styles during migration
- No breaking changes to existing installations

## Performance

The abstraction layer adds minimal overhead:

- Plugin loading: ~10ms
- Function calls: ~1ms per call
- Package name mapping: ~0.1ms per package

Total impact: < 100ms for typical installation script

## Troubleshooting

### Plugin Not Found
```
❌ Distribution plugin not found: /path/to/plugin.sh
```
**Solution:** Your distribution is not yet supported. File an issue or create a plugin.

### Plugin Failed to Load
```
❌ Plugin failed to load: ubuntu
```
**Solution:** Plugin file is corrupt or has syntax errors. Check bash syntax.

### Package Not Found
```
❌ Package 'xyz' not found
```
**Solution:** 
1. Check if package name is correct for your distro
2. Add mapping to `package-mapping.yaml`
3. Update plugin's `distro_map_package()` function

## Contributing

We welcome contributions for:

- New distribution plugins
- Package name mappings
- Bug fixes
- Documentation improvements
- Test coverage

See `../docs/CONTRIBUTING.md` for guidelines.

## License

Same as Bentobox main project.

