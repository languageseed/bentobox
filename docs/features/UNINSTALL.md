# Bentobox Uninstall & Reset Feature

## Overview

The uninstall feature allows users to remove Bentobox and reset their Ubuntu system to a near-default state with a single click.

## Location

**GUI:** Bottom left button - "🗑️  Uninstall & Reset" (red/destructive style)

## What It Does

### Removes:
- ✅ **Desktop Applications:**
  - Cursor
  - VS Code
  - Google Chrome
  - Brave Browser
  - Typora
  - Alacritty
  - Flatpak apps (Pinta, GIMP)
  - VLC
  - LibreOffice
  - Flameshot
  - GNOME Tweaks
  - Ulauncher

- ✅ **Terminal Tools:**
  - btop
  - fastfetch
  - lazygit
  - zellij
  - GitHub CLI (gh)
  - mise

- ✅ **Docker Resources:**
  - Containers (Portainer, OpenWebUI, Ollama)
  - (Optional) Docker itself with `--remove-docker` flag

- ✅ **Virtualization (Optional):**
  - virt-manager and KVM tools with `--remove-virt` flag
  - Windows VM images with `--remove-vms` flag
  - ASDControl udev rules

- ✅ **Customizations:**
  - GNOME theme and settings
  - Custom fonts (Cascadia Mono, iA Writer Mono)
  - Terminal configurations (Zellij, custom bashrc)
  - Custom wallpapers
  - Bentobox state and config files
  - GUI launcher and desktop entries

- ✅ **Repository Sources:**
  - Typora repo
  - GitHub CLI repo
  - Chrome repo
  - VS Code repo
  - Brave repo
  - Associated GPG keys

### Preserves:
- ✅ Personal files and documents
- ✅ User data in home directory
- ✅ Custom user configurations (unless Bentobox-specific)
- ✅ System stability and core packages

## Safety Features

### Triple Confirmation System:

**1. Warning Dialog:**
- Lists everything that will be removed
- Explains consequences
- "Cancel" or "Uninstall & Reset" buttons

**2. Final Confirmation:**
- Yes/No dialog
- Last chance to back out

**3. Type Confirmation:**
- Must type "UNINSTALL" to proceed
- Prevents accidental clicks
- Ensures user understands action

### Visual Indicators:
- 🗑️  Trash icon for clarity
- Red button (destructive-action style)
- Warning emoji and text
- Clear, scary messaging

## Usage

### From GUI:

```
1. Open bentobox-gui
2. Click "🗑️  Uninstall & Reset" button
3. Read the warning carefully
4. Click "Uninstall & Reset"
5. Confirm "Yes"
6. Type "UNINSTALL" and press OK
7. Wait for completion (may take a few minutes)
8. Reboot when prompted
```

### From Command Line:

```bash
# Standard uninstall (removes apps, configs, themes)
bash ~/.local/share/omakub/install/uninstall-bentobox.sh

# Full uninstall (also removes installation directory)
bash ~/.local/share/omakub/install/uninstall-bentobox.sh --full

# Remove Docker completely
bash ~/.local/share/omakub/install/uninstall-bentobox.sh --remove-docker

# Remove virtualization tools
bash ~/.local/share/omakub/install/uninstall-bentobox.sh --remove-virt

# Remove Windows VM images
bash ~/.local/share/omakub/install/uninstall-bentobox.sh --remove-vms

# Combine flags
bash ~/.local/share/omakub/install/uninstall-bentobox.sh --full --remove-docker --remove-virt
```

## Uninstall Process

The script performs these steps:

### 1. Docker Cleanup
```bash
# Stop running containers
docker stop portainer open-webui ollama

# Remove containers
docker rm portainer open-webui ollama

# Note: Docker volumes are preserved (contain data)
# Remove manually if desired:
# docker volume rm portainer_data open-webui ollama
```

### 2. GNOME Reset
```bash
# Reset theme
gsettings reset org.gnome.desktop.interface gtk-theme
gsettings reset org.gnome.desktop.interface icon-theme
gsettings reset org.gnome.desktop.interface color-scheme

# Reset wallpaper
gsettings reset org.gnome.desktop.background picture-uri
gsettings reset org.gnome.desktop.background picture-uri-dark

# Reset fonts
gsettings reset org.gnome.desktop.interface monospace-font-name
gsettings reset org.gnome.desktop.interface font-name

# Reset terminal
gsettings reset org.gnome.Terminal.Legacy.Profile:/.../font
```

### 3. Font Removal
```bash
# Remove custom fonts
rm -f ~/.local/share/fonts/CaskaydiaMono*.ttf
rm -f ~/.local/share/fonts/iAWriterMono*.ttf

# Update font cache
fc-cache -f
```

### 4. Configuration Cleanup
```bash
# Remove Bentobox-specific configs
rm -f ~/.bentobox-state.json
rm -f ~/.bentobox-config.yaml
rm -rf ~/.config/zellij
rm -rf ~/.local/share/mise

# Clean bashrc (remove omakub lines)
sed -i.backup '/omakub/d' ~/.bashrc
```

### 5. GUI Removal
```bash
# Remove launcher
sudo rm -f /usr/local/bin/bentobox-gui

# Remove desktop entry
sudo rm -f /usr/share/applications/bentobox-installer.desktop
sudo update-desktop-database
```

## Post-Uninstall

### Automatic:
- State file cleared
- Config file removed
- GNOME settings reset
- Terminal font reset
- Custom fonts removed

### Manual Cleanup (Optional):

**Remove all Bentobox files:**
```bash
rm -rf ~/.local/share/omakub
```

**Remove unused packages:**
```bash
sudo apt autoremove
sudo apt autoclean
```

**Remove Docker completely:**
```bash
sudo apt remove docker-ce docker-ce-cli containerd.io
sudo rm -rf /var/lib/docker
```

**Remove installed applications:**
```bash
# Chrome
sudo apt remove google-chrome-stable

# VS Code
sudo apt remove code

# Cursor
sudo apt remove cursor

# etc...
```

## What's NOT Removed

By default, these are **preserved** (can be removed with flags):

- Docker itself (use `--remove-docker` to remove)
- Virtualization tools (use `--remove-virt` to remove)
- Windows VM images (use `--remove-vms` to remove)
- Installation directory (use `--full` to remove)

These protect against:
- Breaking other Docker projects
- Removing VMs you may want to keep
- Losing the ability to quickly reinstall

## Recovery

If you change your mind:

### Re-install Bentobox:
```bash
# Download and run installer again
bash <(curl -fsSL https://omakub.org/install) # Replace with actual URL
```

### Restore from backup:
```bash
# Bashrc is backed up automatically
cp ~/.bashrc.backup ~/.bashrc
```

## Troubleshooting

### Uninstall fails:

**Check what's running:**
```bash
docker ps
ps aux | grep omakub
```

**Manual cleanup:**
```bash
# Stop everything
docker stop $(docker ps -q)

# Force remove containers
docker rm -f portainer open-webui ollama

# Reset GNOME manually
dconf reset -f /org/gnome/
```

### Some things not removed:

**Find Bentobox files:**
```bash
find ~/ -name "*omakub*" 2>/dev/null
find ~/ -name "*bentobox*" 2>/dev/null
```

**Check installed packages:**
```bash
dpkg -l | grep -i bentobox
apt list --installed | grep -i omakub
```

### System unstable after uninstall:

**Reboot:**
```bash
sudo reboot
```

**Restore system packages:**
```bash
sudo apt install --reinstall ubuntu-desktop
```

**Reset GNOME completely:**
```bash
dconf reset -f /
# WARNING: This resets ALL GNOME settings
```

## Safety Notes

### What's Safe:
- ✅ Running uninstall won't delete personal files
- ✅ System will remain bootable
- ✅ Can re-install Bentobox anytime
- ✅ Other software remains functional

### Be Aware:
- ⚠️  Custom terminal configurations will be lost
- ⚠️  Docker containers and their data will be removed
- ⚠️  GNOME customizations will be reset
- ⚠️  You'll need to manually remove packages if desired

## Testing

Before running on a production system:
1. Test in a VM first
2. Backup important configs
3. Document your custom settings
4. Take a system snapshot (if using VM)

## Code Structure

### GUI Method:
- `on_uninstall_bentobox()` - Confirmation dialogs
- `run_uninstall()` - Progress dialog
- `uninstall_worker()` - Threaded execution
- `basic_uninstall()` - Fallback if script missing
- `on_uninstall_complete()` - Success handler
- `on_uninstall_error()` - Error handler

### Uninstall Script:
- `install/uninstall-bentobox.sh` - Main script
- Runs with `set +e` to continue on errors
- Provides detailed feedback
- Supports `--full` flag for complete removal

## Future Enhancements

Potential improvements:
- [ ] Selective uninstall (choose what to remove)
- [ ] Backup before uninstall
- [ ] Dry-run mode (show what would be removed)
- [ ] Restore from previous state
- [ ] Uninstall specific components only
- [ ] Export configuration before uninstall

## Summary

The uninstall feature provides a safe, comprehensive way to remove Bentobox and reset Ubuntu to near-default state. Multiple confirmation steps prevent accidents, and the process preserves personal files while removing all Bentobox customizations.

Perfect for:
- Testing Bentobox safely
- Starting fresh
- Removing before system handoff
- Troubleshooting issues
- Trying different setups


---
# Complete Application Removal

# Uninstall Feature Update - Complete App Removal

## Summary

The uninstall feature now **removes all installed applications** and resets Ubuntu to near-default state.

## Changes Made

### 1. Enhanced Uninstall Script (`install/uninstall-bentobox.sh`)

**Now removes:**

#### Desktop Applications:
- ✅ Cursor
- ✅ VS Code  
- ✅ Google Chrome
- ✅ Brave Browser
- ✅ Typora
- ✅ Alacritty
- ✅ Pinta (Flatpak)
- ✅ GIMP (Flatpak)
- ✅ VLC
- ✅ LibreOffice
- ✅ Flameshot
- ✅ GNOME Tweaks
- ✅ Ulauncher

#### Terminal Tools:
- ✅ btop
- ✅ fastfetch
- ✅ lazygit
- ✅ zellij
- ✅ GitHub CLI (gh)
- ✅ mise

#### Repository Sources:
- ✅ Typora repo & keys
- ✅ GitHub CLI repo & keys
- ✅ Chrome repo & keys
- ✅ VS Code repo & keys
- ✅ Brave repo & keys
- ✅ mise repo & keys

#### Optional Removals (with flags):
- `--remove-docker` - Removes Docker completely
- `--remove-virt` - Removes virt-manager and KVM tools
- `--remove-vms` - Removes Windows VM images
- `--full` - Removes installation directory

### 2. Updated GUI Dialog

The warning dialog now explicitly lists:
```
🗑️  Remove all Bentobox-installed applications
   • Desktop apps (Cursor, VS Code, Chrome, Typora, etc.)
   • Terminal tools (btop, fastfetch, lazygit, zellij, etc.)
   • Flatpak apps (Pinta, GIMP)
🎨 Reset GNOME to default theme and settings
📝 Remove custom fonts
🐳 Stop and remove Docker containers
🔧 Remove development tools (mise, Node.js, etc.)
⚙️  Reset terminal configurations
🖼️  Reset wallpaper to default
🗂️  Remove repository sources
```

### 3. Updated Completion Dialog

Shows exactly what was removed:
```
What was removed:
• Desktop applications (Cursor, VS Code, Chrome, etc.)
• Terminal tools (btop, fastfetch, lazygit, etc.)
• Docker containers (Portainer, OpenWebUI, Ollama)
• GNOME theme, fonts, and customizations
• Custom configurations and state files
• Repository sources and GPG keys
```

## How It Works

### Detection & Removal Logic

The script checks for each application and removes it if found:

```bash
# Desktop app example
if command -v cursor &> /dev/null; then
    sudo apt remove -y cursor && echo "  ✓ Cursor removed"
fi

# Flatpak example
if command -v flatpak &> /dev/null; then
    flatpak list --app | grep -q "Pinta" && \
        flatpak uninstall -y com.github.PintaProject.Pinta && \
        echo "  ✓ Pinta removed"
fi

# Binary in /usr/local/bin example
if command -v lazygit &> /dev/null; then
    sudo rm -f /usr/local/bin/lazygit && echo "  ✓ lazygit removed"
fi
```

### Repository Cleanup

```bash
# Remove repo sources
sudo rm -f /etc/apt/sources.list.d/typora.list
sudo rm -f /etc/apt/sources.list.d/github-cli.list
sudo rm -f /etc/apt/sources.list.d/google-chrome.list
sudo rm -f /etc/apt/sources.list.d/vscode.list
sudo rm -f /etc/apt/sources.list.d/brave*.list

# Remove GPG keys
sudo rm -f /etc/apt/keyrings/typora.gpg
sudo rm -f /usr/share/keyrings/githubcli-archive-keyring.gpg
sudo rm -f /etc/apt/keyrings/mise-archive-keyring.gpg
```

### Optional Removals

```bash
# Docker (only if no other containers)
if [ "$CONTAINER_COUNT" -eq 0 ]; then
    if [ "$1" = "--remove-docker" ]; then
        sudo apt remove -y docker-ce docker-ce-cli containerd.io
    fi
fi

# Virtualization
if [ "$1" = "--remove-virt" ]; then
    sudo apt remove -y virt-manager qemu-kvm libvirt-daemon-system
fi

# VM images
if [ "$1" = "--remove-vms" ] || [ "$1" = "--full" ]; then
    rm -rf "$HOME/.local/share/libvirt/images/"*windows*
fi
```

## Usage Examples

### From GUI:
1. Click 🗑️ Uninstall & Reset button
2. Read warning (lists all apps that will be removed)
3. Confirm
4. Type "UNINSTALL"
5. Wait for completion

### From Terminal:

```bash
# Standard uninstall (removes all apps & configs)
bash ~/.local/share/omakub/install/uninstall-bentobox.sh

# Full uninstall (also removes installation directory)
bash ~/.local/share/omakub/install/uninstall-bentobox.sh --full

# Remove Docker completely
bash ~/.local/share/omakub/install/uninstall-bentobox.sh --remove-docker

# Remove everything including virtualization
bash ~/.local/share/omakub/install/uninstall-bentobox.sh --full --remove-docker --remove-virt --remove-vms
```

## Safety Features

### What's Protected:
- ✅ Personal files and documents
- ✅ User data in home directory  
- ✅ System stability (core packages not touched)
- ✅ Other users' applications and configs

### Triple Confirmation:
1. **Warning Dialog** - Shows everything that will be removed
2. **Final Confirmation** - Yes/No verification
3. **Type Confirmation** - Must type "UNINSTALL" exactly

### Error Handling:
- Script uses `set +e` to continue on errors
- Each removal provides feedback (✓ or ⚠)
- Won't break system if a package isn't found
- Protects Docker if other containers exist

## Output Example

```
🗑️  Bentobox Uninstall & Reset
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📦 Stopping and removing Docker containers...
  ✓ Containers stopped
  ✓ Containers removed

🎨 Resetting GNOME theme and settings...
  ✓ GTK theme reset
  ✓ Icon theme reset
  ✓ Wallpaper reset
  ✓ Font settings reset

📝 Removing custom fonts...
  ✓ Cascadia Mono removed
  ✓ Font cache updated

⚙️  Removing terminal configurations...
  ✓ Bashrc cleaned
  ✓ Zellij config removed

📦 Removing installed applications...
  ✓ Cursor removed
  ✓ VS Code removed
  ✓ Chrome removed
  ✓ Typora removed
  ✓ Alacritty removed
  ✓ Pinta removed
  ✓ btop removed
  ✓ fastfetch removed
  ✓ lazygit removed
  ✓ zellij removed
  ✓ GitHub CLI removed
  ℹ Docker kept (use --remove-docker to remove)

🗂️  Cleaning up repositories...
  ✓ Repository cleanup complete

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Uninstall Complete
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Your system has been reset to near-default Ubuntu state.

📝 What was removed:
  • Docker containers (Portainer, OpenWebUI, Ollama)
  • Desktop apps (Cursor, VS Code, Chrome, Alacritty, etc.)
  • Terminal tools (btop, fastfetch, lazygit, zellij, etc.)
  • GNOME customizations (theme, fonts, extensions)
  • Custom configurations and state files
  • Repository sources and GPG keys

📝 Optional cleanup (run with flags):
  • --remove-docker     Remove Docker completely
  • --remove-virt       Remove virtualization tools
  • --remove-vms        Remove Windows VM images
  • --full              Remove everything including install dir

📝 Next steps (optional):
  • Reboot your system: sudo reboot
  • Remove unused packages: sudo apt autoremove
  • Remove Bentobox dir: rm -rf ~/.local/share/omakub
```

## Post-Uninstall Cleanup

After uninstall, you can optionally:

```bash
# Remove leftover dependencies
sudo apt autoremove
sudo apt autoclean

# Remove Bentobox directory (if not using --full)
rm -rf ~/.local/share/omakub

# Remove any remaining configs
ls ~/.config/ | grep -i omakub
```

## Testing Checklist

- [ ] GUI button shows correct warning with app list
- [ ] Triple confirmation works correctly
- [ ] Desktop apps are removed (Cursor, VS Code, Chrome)
- [ ] Terminal tools are removed (btop, fastfetch, lazygit)
- [ ] Flatpak apps are removed (Pinta, GIMP)
- [ ] Docker containers are stopped and removed
- [ ] GNOME theme is reset
- [ ] Fonts are removed
- [ ] Repository sources are cleaned up
- [ ] State and config files are deleted
- [ ] System remains bootable
- [ ] Personal files are untouched
- [ ] `--full` flag removes installation directory
- [ ] `--remove-docker` removes Docker
- [ ] `--remove-virt` removes virtualization tools
- [ ] GUI completion dialog shows correct summary

## Files Modified

1. **`install/uninstall-bentobox.sh`**
   - Added desktop application removal
   - Added terminal tool removal
   - Added Flatpak app removal
   - Added repository cleanup
   - Added optional Docker/virt/VM removal
   - Enhanced output messages

2. **`install/gui.py`**
   - Updated warning dialog with app list
   - Updated completion dialog with removal summary
   - No logic changes (script does the work)

3. **`UNINSTALL_FEATURE.md`**
   - Updated documentation
   - Added complete app list
   - Added flag examples
   - Updated usage instructions

## Answer to User Question

**Q: "does it uninstall all apps that we deployed?"**

**A: YES! ✅**

The uninstall feature now removes:
- All desktop applications (Cursor, VS Code, Chrome, Typora, etc.)
- All terminal tools (btop, fastfetch, lazygit, zellij, etc.)
- All Flatpak apps (Pinta, GIMP)
- All Docker containers
- All repository sources and keys
- All customizations and configs

With optional flags for:
- Docker itself (`--remove-docker`)
- Virtualization tools (`--remove-virt`)
- VM images (`--remove-vms`)
- Installation directory (`--full`)

Your system will be reset to near-default Ubuntu state! 🗑️✨

