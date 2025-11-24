# Bentobox Extensibility Analysis & Guide

## Executive Summary

**Current State: ⚠️ PARTIALLY EXTENSIBLE**

- ✅ **Installation Scripts:** Fully extensible (auto-discovery)
- ⚠️ **GUI Application List:** Hardcoded (requires manual editing)
- ⚠️ **Pre-Installation Menu:** Hardcoded (requires manual editing)
- ✅ **Themes:** Extensible (convention-based discovery)
- ❌ **Languages & Containers:** Hardcoded in GUI
- ✅ **GNOME Customizations:** Extensible (script-based)

---

## Current Extensibility Status

### ✅ **FULLY EXTENSIBLE: Installation Scripts**

#### How It Works:
```python
# install/orchestrator.py lines 84-127
def discover_components(self):
    """Scan install scripts and build component registry"""
    
    # Terminal components (always needed)
    terminal_dir = self.omakub_path / 'install/terminal'
    for script in terminal_dir.glob('*.sh'):
        # AUTO-DISCOVERS all .sh files
        self.components[name] = Component(...)
    
    # Desktop components
    desktop_dir = self.omakub_path / 'install/desktop'
    for script in desktop_dir.glob('app-*.sh'):
        # AUTO-DISCOVERS all app-*.sh files
        self.components[name] = Component(...)
    
    # Optional components
    optional_dir = self.omakub_path / 'install/desktop/optional'
    for script in optional_dir.glob('*.sh'):
        # AUTO-DISCOVERS all .sh files
        self.components[name] = Component(...)
```

#### ✅ To Add a New Package:

**Example: Adding Slack**

1. Create script:
```bash
# install/desktop/optional/app-slack.sh
#!/bin/bash

if command -v slack &> /dev/null; then
    echo "Slack already installed, skipping..."
    exit 0
fi

echo "Installing Slack..."
sudo snap install slack
exit 0
```

2. **That's it!** The orchestrator will auto-discover it.

**No other changes needed** - script is automatically:
- Discovered by orchestrator
- Added to component registry
- Included in installation plan
- Tracked in state file

---

### ⚠️ **PARTIALLY EXTENSIBLE: Themes**

#### How It Works:
Themes follow a **convention-based** structure. Each theme needs these files:

```
themes/your-theme/
├── gnome.sh          # GNOME settings
├── alacritty.toml    # Terminal colors
├── zellij.kdl        # Terminal multiplexer theme
├── btop.theme        # System monitor theme
├── neovim.lua        # Editor theme
├── vscode.sh         # VS Code theme installation
├── tophat.sh         # Tophat extension theme (optional)
└── background.jpg    # Wallpaper
```

#### ✅ To Add a New Theme:

**Example: Adding "Dracula" theme**

1. Create directory:
```bash
mkdir themes/dracula
```

2. Create `gnome.sh`:
```bash
#!/bin/bash
OMAKUB_THEME_COLOR="purple"
OMAKUB_THEME_BACKGROUND="dracula/background.jpg"
source $OMAKUB_PATH/themes/set-gnome-theme.sh
```

3. Create `alacritty.toml`:
```toml
[colors.primary]
background = '#282a36'
foreground = '#f8f8f2'

[colors.normal]
black   = '#000000'
red     = '#ff5555'
green   = '#50fa7b'
# ... etc
```

4. Create other theme files following the pattern from existing themes.

5. **Manual step required:** Add to GUI dropdown:
```python
# install/gui.py line ~540
themes = [
    ("tokyo-night", "Tokyo Night"),
    ("gruvbox", "Gruvbox"),
    ("nord", "Nord"),
    ("dracula", "Dracula"),  # ADD THIS
]
```

**Status:** Mostly extensible, but GUI list is hardcoded.

---

### ❌ **NOT EXTENSIBLE: GUI Component Lists**

#### Current Problem:

The GUI has **hardcoded lists** of applications, languages, and containers:

```python
# install/gui.py lines 438-449
apps = [
    ("1password", "1Password - Password Manager"),
    ("cursor", "Cursor - AI Code Editor"),
    ("tailscale", "Tailscale - Mesh VPN"),
    ("brave", "Brave - Privacy Browser"),
    ("chrome", "Google Chrome"),
    # HARDCODED - must edit this file to add new apps
]

# lines 468-477
languages = [
    ("Node.js", "Node.js - JavaScript Runtime"),
    ("Python", "Python - Programming Language"),
    # HARDCODED
]

# lines 496-500
containers = [
    ("Portainer", "Portainer - Docker Management UI"),
    ("OpenWebUI", "OpenWebUI - AI Chat Interface"),
    # HARDCODED
]
```

#### ❌ To Add a New App Currently:

**Example: Adding Slack to GUI**

1. Create the installation script (auto-discovered ✅)
2. **Edit GUI code manually:**
```python
# install/gui.py line ~450
apps = [
    # ... existing apps ...
    ("slack", "Slack - Team Communication"),  # ADD THIS
]
```

**Problem:** Requires editing Python code, not user-friendly.

---

### ❌ **NOT EXTENSIBLE: Pre-Installation Menu**

#### Current Problem:

The TUI menu also has **hardcoded lists**:

```bash
# install/pre-installation-menu.sh
OPTIONAL_APPS=$(gum choose --no-limit \
    "1Password" \
    "Cursor" \
    "Tailscale" \
    "Brave" \
    "Chrome"
    # HARDCODED - must edit to add new apps
)
```

**Problem:** Adding a new app requires editing this bash script.

---

## Extensibility Recommendations

### 🔧 **PRIORITY 1: Make GUI Component Lists Dynamic**

#### Current State:
```python
# Hardcoded in gui.py
apps = [("cursor", "Cursor - AI Code Editor"), ...]
```

#### Recommended Solution:
```python
def discover_available_apps(self):
    """Auto-discover available optional apps from filesystem"""
    apps = []
    optional_dir = self.omakub_path / 'install/desktop/optional'
    
    for script in optional_dir.glob('app-*.sh'):
        app_id = script.stem.replace('app-', '')
        
        # Read display name from script comment or metadata
        display_name = self._read_app_metadata(script)
        
        apps.append((app_id, display_name))
    
    return sorted(apps, key=lambda x: x[1])

def _read_app_metadata(self, script_path):
    """Read metadata from script comments"""
    # Look for: # NAME: Cursor - AI Code Editor
    with open(script_path) as f:
        for line in f:
            if line.startswith('# NAME:'):
                return line.split(':', 1)[1].strip()
    
    # Fallback to script name
    return script_path.stem.replace('app-', '').replace('-', ' ').title()
```

#### Usage in Scripts:
```bash
#!/bin/bash
# NAME: Slack - Team Communication
# DESCRIPTION: Messaging platform for teams
# CATEGORY: Communication

if command -v slack &> /dev/null; then
    echo "Slack already installed, skipping..."
    exit 0
fi

echo "Installing Slack..."
sudo snap install slack
```

**Benefit:** Drop in a new script → automatically appears in GUI!

---

### 🔧 **PRIORITY 2: Make Pre-Installation Menu Dynamic**

#### Recommended Solution:
```bash
#!/bin/bash
# install/pre-installation-menu.sh

# Auto-discover available optional apps
AVAILABLE_APPS=()
for script in $OMAKUB_PATH/install/desktop/optional/app-*.sh; do
    app_name=$(basename "$script" .sh | sed 's/app-//' | sed 's/-/ /g' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2));}1')
    
    # Read display name from script if available
    display_name=$(grep "^# NAME:" "$script" | sed 's/# NAME: //')
    
    if [ -n "$display_name" ]; then
        AVAILABLE_APPS+=("$display_name")
    else
        AVAILABLE_APPS+=("$app_name")
    fi
done

# Use discovered apps in menu
OPTIONAL_APPS=$(gum choose --no-limit "${AVAILABLE_APPS[@]}")
```

**Benefit:** Menu automatically updates when new scripts are added.

---

### 🔧 **PRIORITY 3: Theme Auto-Discovery**

#### Current State:
GUI has hardcoded theme list:
```python
themes = [
    ("tokyo-night", "Tokyo Night"),
    ("gruvbox", "Gruvbox"),
    # ... hardcoded ...
]
```

#### Recommended Solution:
```python
def discover_available_themes(self):
    """Auto-discover themes from themes directory"""
    themes = []
    themes_dir = self.omakub_path / 'themes'
    
    for theme_dir in themes_dir.iterdir():
        if theme_dir.is_dir() and (theme_dir / 'gnome.sh').exists():
            theme_id = theme_dir.name
            
            # Read display name from metadata or format directory name
            display_name = self._read_theme_metadata(theme_dir)
            
            themes.append((theme_id, display_name))
    
    return sorted(themes, key=lambda x: x[1])

def _read_theme_metadata(self, theme_dir):
    """Read theme metadata"""
    metadata_file = theme_dir / 'metadata.txt'
    if metadata_file.exists():
        with open(metadata_file) as f:
            for line in f:
                if line.startswith('NAME:'):
                    return line.split(':', 1)[1].strip()
    
    # Fallback to directory name
    return theme_dir.name.replace('-', ' ').title()
```

#### Theme Metadata File:
```
# themes/dracula/metadata.txt
NAME: Dracula
DESCRIPTION: A dark theme for the masses
AUTHOR: Dracula Team
COLORS: purple, pink, cyan
```

---

### 🔧 **PRIORITY 4: Plugin System**

#### Recommended: Plugin Registry

Create a standardized way to add extensions:

```yaml
# ~/.bentobox-plugins.yaml
plugins:
  - name: slack
    type: desktop_app
    display_name: "Slack - Team Communication"
    category: "Communication"
    script: "install/desktop/optional/app-slack.sh"
    icon: "slack.png"
    
  - name: dracula
    type: theme
    display_name: "Dracula"
    description: "Dark theme for the masses"
    path: "themes/dracula"
    
  - name: go
    type: language
    display_name: "Go"
    script: "install/languages/go.sh"
```

Then modify orchestrator to read this registry:
```python
def load_plugins(self):
    """Load user-defined plugins"""
    plugin_file = self.home / '.bentobox-plugins.yaml'
    if plugin_file.exists():
        with open(plugin_file) as f:
            plugins = yaml.safe_load(f)
            
        for plugin in plugins.get('plugins', []):
            if plugin['type'] == 'desktop_app':
                self.add_desktop_app(plugin)
            elif plugin['type'] == 'theme':
                self.add_theme(plugin)
            # ... etc
```

---

## Current Workarounds

### Adding a New Application (Current Method)

**Steps:**

1. **Create installation script** (auto-discovered ✅):
```bash
# install/desktop/optional/app-slack.sh
#!/bin/bash

if command -v slack &> /dev/null; then
    echo "Slack already installed, skipping..."
    exit 0
fi

echo "Installing Slack..."
sudo snap install slack
```

2. **Edit GUI code** (❌ manual):
```python
# install/gui.py line ~438
apps = [
    # ... existing ...
    ("slack", "Slack - Team Communication"),
]
```

3. **Edit TUI menu** (❌ manual):
```bash
# install/pre-installation-menu.sh
OPTIONAL_APPS=$(gum choose --no-limit \
    "1Password" \
    "Cursor" \
    "Slack"  # ADD THIS
)
```

4. **Update uninstall** (optional):
```bash
# install/uninstall-bentobox.sh
if command -v slack &> /dev/null; then
    sudo snap remove slack && echo "  ✓ Slack removed"
fi
```

---

### Adding a New Theme (Current Method)

**Steps:**

1. **Create theme directory**:
```bash
mkdir themes/dracula
```

2. **Create theme files** (convention-based ✅):
- `gnome.sh`
- `alacritty.toml`
- `zellij.kdl`
- `btop.theme`
- `neovim.lua`
- `vscode.sh`
- `background.jpg`

3. **Edit GUI** (❌ manual):
```python
# install/gui.py line ~540
themes = [
    # ... existing ...
    ("dracula", "Dracula"),
]
```

---

## Recommended Improvements

### Implementation Roadmap

#### Phase 1: Script Metadata (Quick Win)
**Effort:** Low | **Impact:** High

Add metadata comments to installation scripts:
```bash
#!/bin/bash
# NAME: Slack - Team Communication
# DESCRIPTION: Messaging platform for teams
# CATEGORY: Communication
# ICON: slack
# CHECK: slack
```

Modify GUI to read these comments instead of hardcoded lists.

**Files to modify:**
- `install/gui.py` - Add `discover_available_apps()`
- `install/orchestrator.py` - Add `_read_script_metadata()`
- All existing scripts - Add metadata comments

**Time estimate:** 4-6 hours

---

#### Phase 2: Dynamic Component Discovery (Medium)
**Effort:** Medium | **Impact:** High

Make GUI and TUI menus dynamically discover components:

1. GUI discovers apps from filesystem
2. TUI discovers apps from filesystem
3. Remove all hardcoded lists

**Files to modify:**
- `install/gui.py` - Rewrite `build_selection_tab()`
- `install/pre-installation-menu.sh` - Add discovery logic
- `install/orchestrator.py` - Enhance discovery

**Time estimate:** 8-12 hours

---

#### Phase 3: Theme Auto-Discovery (Medium)
**Effort:** Medium | **Impact:** Medium

1. Add `metadata.txt` to each theme directory
2. GUI auto-discovers themes
3. Desktop customization tab becomes dynamic

**Files to modify:**
- `install/gui.py` - Add `discover_available_themes()`
- All theme directories - Add `metadata.txt`

**Time estimate:** 4-6 hours

---

#### Phase 4: Plugin Registry (Advanced)
**Effort:** High | **Impact:** High

Full plugin system with registry:

1. Create `~/.bentobox-plugins.yaml` format
2. Add plugin loading to orchestrator
3. GUI reads from plugin registry
4. Documentation for creating plugins

**New files:**
- `install/plugin-manager.py`
- `PLUGIN_DEVELOPMENT_GUIDE.md`

**Time estimate:** 16-24 hours

---

## Summary

### Current Extensibility Score: 6/10

| Feature | Extensible? | How? | Improvement Needed? |
|---------|-------------|------|---------------------|
| **Installation Scripts** | ✅ Yes | Auto-discovery | None |
| **Themes (Files)** | ✅ Yes | Convention-based | None |
| **Themes (GUI List)** | ❌ No | Hardcoded | High priority |
| **Desktop Apps (GUI)** | ❌ No | Hardcoded | High priority |
| **Languages (GUI)** | ❌ No | Hardcoded | Medium priority |
| **Containers (GUI)** | ❌ No | Hardcoded | Medium priority |
| **TUI Menu** | ❌ No | Hardcoded | High priority |
| **GNOME Settings** | ✅ Yes | Script-based | None |
| **Uninstall** | ⚠️ Partial | Semi-hardcoded | Low priority |

### Quick Wins:

1. **Add script metadata comments** (4-6 hours)
2. **Make GUI discovery dynamic** (8-12 hours)
3. **Make TUI menu dynamic** (4-6 hours)

**Total time for full extensibility: ~20 hours**

### After Improvements:

**To add a new package:**
1. Drop `app-slack.sh` in `install/desktop/optional/`
2. Add metadata comment at top of script
3. Done! ✅ (appears in GUI, TUI, orchestrator)

**To add a new theme:**
1. Create `themes/dracula/` with required files
2. Add `metadata.txt` with theme info
3. Done! ✅ (appears in GUI theme dropdown)

---

## Conclusion

**Current state:** Bentobox is **partially extensible**. The backend (orchestrator) is fully dynamic, but the frontend (GUI and TUI) has hardcoded lists.

**Recommended action:** Implement Phase 1 and Phase 2 to make the system fully extensible with minimal effort.

**Benefit:** Users can add new packages/themes by simply dropping files in the appropriate directories, without editing any Python or bash code.

