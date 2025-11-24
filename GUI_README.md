# Bentobox GUI Installer

A simple, user-friendly desktop application for managing Bentobox installation.

## Features

### 📦 Component Selection Tab
- **Desktop Applications**: Select optional apps like Cursor, Chrome, Tailscale, etc.
- **Programming Languages**: Choose which languages to install (Node.js, Python, Ruby, Go, etc.)
- **Docker Containers**: Pick containers (Portainer, OpenWebUI, Ollama)
- Visual checkboxes with descriptions
- Saves preferences to `~/.bentobox-config.yaml`

### ▶️ Installation Tab
- **Embedded Terminal**: Watch installation progress in real-time
- **Progress Bar**: Visual feedback on installation status
- **Live Output**: See exactly what's happening during installation
- **Error Handling**: Installation continues even if individual components fail

### 📊 Status Tab
- **Installation Summary**: Quick overview of what's installed
- **Component Details**: See status of every component
- **Refresh Button**: Update status on demand
- **Color-coded Icons**:
  - ✅ Successfully installed
  - 📦 Already installed
  - ⚠️ Failed (with error message)
  - ⏭️ Skipped

## Installation

### From Terminal

```bash
cd ~/.local/share/omakub
bash install-gui.sh
```

This will:
1. Install GTK dependencies (`python3-gi`, `gir1.2-vte-2.91`, `zenity`)
2. Install Python dependencies (`pyyaml`)
3. Copy launcher to `/usr/local/bin/bentobox-gui`
4. Install desktop menu entry

### Manual Installation

```bash
sudo apt install python3-gi gir1.2-gtk-3.0 gir1.2-vte-2.91 zenity
python3 -m pip install --user pyyaml
sudo cp bentobox-gui.sh /usr/local/bin/bentobox-gui
sudo chmod +x /usr/local/bin/bentobox-gui
sudo desktop-file-install bentobox-installer.desktop
```

## Usage

### Launch from Desktop

1. Open **Applications** menu
2. Go to **System** → **Bentobox Installer**
3. Or search for "Bentobox" in your app launcher

### Launch from Terminal

```bash
bentobox-gui
```

### Using the GUI

1. **Select Components** (Tab 1):
   - Check the apps, languages, and containers you want
   - Click "💾 Save Configuration" to save your choices

2. **Install** (Tab 2):
   - Click "🚀 Start Installation"
   - Watch progress in the embedded terminal
   - Wait for completion message

3. **Check Status** (Tab 3):
   - View what's installed, failed, or skipped
   - Click "🔄 Refresh Status" to update

## Configuration

The GUI saves your selections to `~/.bentobox-config.yaml`:

```yaml
mode: unattended
desktop:
  optional_apps:
    - cursor
    - tailscale
languages:
  - Node.js
  - Python
containers:
  - Portainer
  - OpenWebUI
settings:
  auto_reboot: false
  verbose: true
```

You can manually edit this file or let the GUI manage it.

## State Tracking

Installation state is saved to `~/.bentobox-state.json`:

```json
{
  "components": {
    "docker": {
      "status": "already_installed",
      "error": null
    },
    "cursor": {
      "status": "installed",
      "error": null
    }
  }
}
```

This ensures:
- Components aren't reinstalled unnecessarily
- You can see what failed and why
- Re-runs are safe and idempotent

## Technical Details

### Architecture

```
┌─────────────────────────┐
│  bentobox-gui.sh        │
│  (Shell wrapper)        │
│  - Checks dependencies  │
│  - Launches Python GUI  │
└─────────────────────────┘
            │
            ▼
┌─────────────────────────┐
│  install/gui.py         │
│  (GTK Application)      │
│  - 3 tabs (UI)          │
│  - Config management    │
│  - Spawns orchestrator  │
└─────────────────────────┘
            │
            ▼
┌─────────────────────────┐
│  orchestrator.py        │
│  (Installation engine)  │
│  - Component discovery  │
│  - State tracking       │
│  - Bash script execution│
└─────────────────────────┘
```

### Dependencies

**System:**
- `python3` (≥ 3.8)
- `python3-gi` (GTK bindings)
- `gir1.2-gtk-3.0` (GTK 3)
- `gir1.2-vte-2.91` (Terminal widget)
- `zenity` (Dialog boxes)

**Python:**
- `PyYAML` (Config file parsing)
- `gi.repository` (GTK bindings)

### File Locations

- **GUI Script**: `~/.local/share/omakub/install/gui.py`
- **Launcher**: `/usr/local/bin/bentobox-gui`
- **Desktop Entry**: `/usr/share/applications/bentobox-installer.desktop`
- **Config**: `~/.bentobox-config.yaml`
- **State**: `~/.bentobox-state.json`

## Troubleshooting

### "No display detected"

The GUI requires a graphical session. Don't run it over SSH without X11 forwarding.

**Solution**: Run from the actual desktop or use `bentobox-cli` instead.

### "Failed to load module 'canberra-gtk-module'"

This is a harmless warning. The GUI will work fine.

**Optional fix**:
```bash
sudo apt install libcanberra-gtk3-module
```

### GUI doesn't start

Check dependencies:
```bash
python3 -c "import gi; gi.require_version('Gtk', '3.0'); gi.require_version('Vte', '2.91')"
```

If this fails, reinstall:
```bash
sudo apt install --reinstall python3-gi gir1.2-gtk-3.0 gir1.2-vte-2.91
```

### PyYAML not found

```bash
python3 -m pip install --user pyyaml
```

## Screenshots

### Component Selection Tab
Select exactly what you want to install with clear descriptions.

### Installation Tab
Watch the installation progress in real-time with an embedded terminal.

### Status Tab
See a complete overview of all components and their installation status.

## CLI Alternative

If you prefer command-line:

```bash
# Interactive (with TUI prompts)
bash install.sh

# Unattended (uses config file)
python3 install/orchestrator.py
```

## Development

To modify the GUI:

1. Edit `install/gui.py`
2. Test: `python3 install/gui.py`
3. Sync to test machine or install locally

### Adding Components

Components are auto-discovered from:
- `install/terminal/*.sh` (always installed)
- `install/desktop/app-*.sh` (desktop apps)
- `install/desktop/optional/*.sh` (optional apps)

To add check commands for new components, update `_get_check_command()` in both:
- `install/orchestrator.py`
- `install/gui.py`

## Future Enhancements

Planned features:
- [ ] Search/filter components
- [ ] Component categories/tags
- [ ] Dependency graph visualization
- [ ] One-click updates
- [ ] Export/import configurations
- [ ] Dark mode
- [ ] Progress percentage per component
- [ ] Estimated time remaining
- [ ] Pause/resume installation

## License

Same as Bentobox (MIT)

