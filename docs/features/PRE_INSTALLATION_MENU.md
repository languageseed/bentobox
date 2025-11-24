# Pre-Installation Component Selection Menu

## Overview

Before the pre-flight check runs, Bentobox now shows an interactive menu where you can select exactly which components to install. This makes it easy to customize your installation without editing config files.

## When Does It Run?

The pre-installation menu appears:
- ✅ **Interactive mode** - When no config file is present
- ❌ **Unattended mode** - Skipped (uses config file)
- ❌ **AI mode** - Skipped (uses config file)

## Menu Flow

```
┌────────────────────────────────────────┐
│   Bentobox Installation Setup          │
└────────────────────────────────────────┘

━━━ Desktop Applications ━━━
  [ ] 1password         (default)
  [ ] ASDControl
  [ ] Audacity
  [ ] Barrier
  [ ] Brave
  [ ] Cursor
  [ ] Discord
  [ ] GIMP
  [ ] Mainline-Kernels
  [ ] OBS-Studio
  [ ] RetroArch
  [ ] RubyMine
  [ ] Sublime-Text
  [ ] Tailscale         (default)
  [ ] VirtualBox
  [ ] WinBoat
  [ ] Windows

  Use ↑/↓ to move, Space to select, Enter to confirm

━━━ Programming Languages ━━━
  [ ] Ruby on Rails
  [x] Node.js           (default)
  [ ] Go
  [ ] PHP
  [x] Python            (default)
  [ ] Elixir
  [ ] Rust
  [ ] Java

  Use ↑/↓ to move, Space to select, Enter to confirm

━━━ Docker Containers ━━━
  [x] Portainer         (default)
  [x] OpenWebUI         (default)
  [ ] Ollama

  Use ↑/↓ to move, Space to select, Enter to confirm

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✓ Component selection complete

Selected components:
  Desktop Apps: 1password, Tailscale
  Languages: Node.js, Python
  Containers: Portainer, OpenWebUI

Next: Pre-flight check will scan for existing installations...
```

## Features

### 1. **Visual Selection with gum**
- Multi-select with spacebar
- Arrow keys to navigate
- Pre-selected defaults
- Categories clearly organized

### 2. **Text-Based Fallback**
If `gum` isn't available or terminal doesn't support it:
```
Available optional applications:
────────────────────────────────────────
  [1] 1password (default)
  [2] ASDControl
  [3] Audacity
  [4] Barrier
  [5] Brave
  [6] Cursor
  ...

Enter numbers (space-separated, or Enter for defaults): 1 3 6
```

### 3. **Smart Defaults**
- Desktop Apps: 1password, Tailscale
- Languages: Node.js, Python  
- Containers: Portainer, OpenWebUI

### 4. **Pre-Flight Integration**
After selections are made:
- Pre-flight check scans for existing installations
- Auto-skip detects what's already installed
- Only installs what you selected AND what's missing

## Example: Complete Flow

```bash
# 1. User runs install
./install.sh

# 2. Terminal check (SSH detection, gum availability)
🖥️  Terminal Compatibility Check
✓ Terminal ready (local with TUI support)

# 3. Pre-Installation Menu (NEW!)
╔════════════════════════════════════════╗
║   Bentobox Installation Setup         ║
╚════════════════════════════════════════╝

[User selects: Cursor, WinBoat, Node.js, Python, Portainer]

# 4. Pre-Flight Check
🔍 Bentobox Pre-flight Check
  ✓ Docker already installed
  ✓ Auto-skip: Will skip Docker installation
  
🔧 Auto-Adjustment Summary
  Skipping 5 already-installed components

# 5. Installation Proceeds
Only installs:
  - Cursor (selected, not installed)
  - WinBoat (selected, not installed)
  - Node.js (selected, not installed)
  - Portainer (selected, not running)

Skips:
  - Docker (not selected, but needed for containers)
  - All other unselected components
```

## Benefits

### ✅ **Visual Clarity**
See ALL available options in one place

### ✅ **No Config File Needed**
Perfect for first-time users

### ✅ **Still Works Over SSH**
Graceful fallback to text-based selection

### ✅ **Smart Combination**
- You choose WHAT to install
- Pre-flight detects WHAT'S ALREADY THERE
- Only installs what's needed

## Usage

### Interactive Install (with TUI menu)
```bash
# Remove any config file to trigger interactive mode
rm ~/.bentobox-config.yaml

# Run install
cd ~/.local/share/omakub
./install.sh
```

### Unattended Install (skip TUI menu)
```bash
# Create config file
cat > ~/.bentobox-config.yaml << 'EOF'
mode: unattended
desktop:
  optional_apps:
    - Cursor
    - WinBoat
languages:
  - Node.js
  - Python
containers:
  - Portainer
EOF

# Run install
./install.sh
```

### Over SSH
```bash
# SSH to target machine
ssh user@machine

# Run install (uses text fallback if no TTY)
cd ~/.local/share/omakub
./install.sh
```

## Implementation

The menu is in `install/pre-installation-menu.sh` and:
1. Checks for GNOME (desktop apps section only shows if desktop detected)
2. Uses `gum choose` for visual selection
3. Falls back to numbered text prompts if gum doesn't work
4. Exports selections as environment variables
5. Shows summary before proceeding to pre-flight

## Status

✅ **Implemented**  
✅ **Tested with gum TUI**  
✅ **Tested with text fallback**  
✅ **Integrated before pre-flight**  
✅ **Works in interactive mode**  
✅ **Skipped in unattended mode**  

---

**Version**: Added Nov 24, 2025

