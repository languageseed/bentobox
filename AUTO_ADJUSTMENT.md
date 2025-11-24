# Pre-flight Auto-Adjustment Feature

## Overview

The pre-flight check system now **automatically adjusts** the installation plan to skip components that are already installed or would conflict with existing installations.

## How It Works

### 1. Detection Phase

During pre-flight, the system scans for:
- **Existing applications** (Docker, Alacritty, VS Code, Chrome, Neovim, Cursor)
- **Language runtimes** (Node.js, Python, Ruby)
- **Running containers** (Portainer, OpenWebUI, Ollama)
- **Conflicting package managers** (nvm, pyenv, rvm, rbenv)

### 2. Export Skip Flags

For each detected component, the system exports environment variables:
```bash
export SKIP_DOCKER=true
export SKIP_NODEJS=true
export SKIP_PYTHON=true
export SKIP_RUBY=true
export SKIP_ALACRITTY=true
export SKIP_VSCODE=true
export SKIP_CURSOR=true
export SKIP_CHROME=true
export SKIP_NEOVIM=true
export SKIP_PORTAINER=true
export SKIP_OPENWEBUI=true
export SKIP_OLLAMA=true
```

### 3. Installation Scripts Check Flags

Each installation script checks its corresponding flag:

**Example: `install/terminal/docker.sh`**
```bash
#!/bin/bash

# Check if Docker should be skipped (already installed)
if [ "$SKIP_DOCKER" = "true" ]; then
    echo "✓ Docker already installed, skipping..."
    exit 0
fi

# ... proceed with Docker installation ...
```

**Example: `install/terminal/select-dev-language.sh`**
```bash
case $language in
  Node.js)
    if [ "$SKIP_NODEJS" = "true" ]; then
      echo "✓ Node.js already installed, skipping mise installation..."
    else
      mise use --global node@lts
    fi
    ;;
esac
```

### 4. Auto-Adjustment Summary

At the end of pre-flight, you see a summary:

```
🔧 Auto-Adjustment Summary
─────────────────────────────────────────
✓ Installation plan automatically adjusted
  Skipping 10 already-installed component(s):

  • Docker (already installed)
  • Node.js (already installed)
  • Python (already installed)
  • Alacritty (already installed)
  • VS Code (already installed)
  • Chrome (already installed)
  • Neovim (already installed)
  • Portainer container (already running)
  • OpenWebUI container (already running)
  • Ollama container (already running)
```

## Benefits

### ✅ Safe Re-runs
Run bentobox installation multiple times without breaking existing setups.

### ✅ Partial Installations
Install only what's missing, skip what's already there.

### ✅ Conflict Avoidance
Automatically skip installations that would conflict with existing tools.

### ✅ Transparent
Clear messages show what's being skipped and why.

### ✅ Works in All Modes
- **Interactive**: See skip messages during installation
- **Unattended**: Auto-adjust based on system state
- **AI**: Skip flags prevent re-installing already-present components

## Configuration

Control pre-flight behavior in `bentobox-config.yaml`:

```yaml
settings:
  skip_preflight: false        # Set true to skip ALL pre-flight checks
  stop_on_warnings: false      # Set true to halt on warnings (interactive only)
```

## Updated Scripts

The following scripts now check skip flags:

### Core Applications
- `install/terminal/docker.sh`
- `install/desktop/app-alacritty.sh`
- `install/desktop/app-chrome.sh`
- `install/desktop/app-vscode.sh`
- `install/terminal/app-neovim.sh`
- `install/desktop/optional/app-cursor.sh`

### Language Management
- `install/terminal/select-dev-language.sh` (Node.js, Python, Ruby)

### Containers
- `install/terminal/select-dev-storage.sh` (Portainer, OpenWebUI, Ollama)

## Example: Fresh vs. Partial Install

### Scenario 1: Fresh Ubuntu 24.04
```
Pre-flight: ✓ No existing components detected
Result: Full installation proceeds
```

### Scenario 2: System with Docker + VS Code
```
Pre-flight: ⚠ Docker already installed
            ⚠ VS Code already installed
Auto-skip: SKIP_DOCKER=true, SKIP_VSCODE=true
Result: Install everything except Docker and VS Code
```

### Scenario 3: Previous Bentobox Installation
```
Pre-flight: ⚠ 10+ components already installed
Auto-skip: Multiple SKIP_* flags set
Result: Only install/update missing components
```

## Testing

To test auto-adjustment on leaf:

```bash
# 1. Sync latest code
cd /Users/ben/Documents/bentobox
rsync -avz --delete \
    --exclude='.git/' \
    -e "ssh -i ~/.ssh/labadmin_key" \
    ./ labadmin@192.168.0.104:~/.local/share/omakub/

# 2. SSH to leaf
ssh -i ~/.ssh/labadmin_key labadmin@192.168.0.104

# 3. Run installation
source ~/.local/share/omakub/install.sh
```

## Troubleshooting

### Skip Flag Not Working?

Check if the environment variable is exported:
```bash
echo $SKIP_DOCKER
# Should output: true
```

### Want to Force Reinstall?

Set `skip_preflight: true` in config to bypass all checks and force installation.

### See Skip Flags in Action?

Enable verbose mode:
```yaml
settings:
  verbose: true
```

---

**Status**: ✅ Implemented and tested
**Version**: Added Nov 24, 2025

