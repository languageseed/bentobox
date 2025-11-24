# Bentobox Extension System - Complete

## Overview

The Bentobox extension system allows community members to easily add new applications, themes, and customizations without modifying core code. Extensions are automatically discovered and integrated into the GUI and installation system.

---

## What's Been Created

### 📚 **Documentation** (3 files)

1. **`EXTENSION_FORMAT_SPEC.md`** (6,000+ words)
   - Complete technical specification
   - Metadata format definition
   - Script structure requirements
   - Theme file specifications
   - Container and language extensions
   - Category reference
   - Testing procedures
   - Contributing guidelines

2. **`EXTENSION_DEVELOPER_GUIDE.md`** (4,500+ words)
   - Quick start tutorial (5 minutes)
   - Step-by-step walkthroughs
   - Real-world examples
   - Common patterns and recipes
   - Troubleshooting guide
   - Best practices
   - Template generator script

3. **`EXTENSIBILITY_ANALYSIS.md`** (3,800+ words)
   - Current extensibility status
   - What works / what doesn't
   - Recommended improvements
   - Implementation roadmap
   - Priority recommendations

### 📄 **Templates** (3 files in `.templates/`)

1. **`app-template.sh`**
   - Complete application script template
   - All metadata fields documented
   - Multiple installation methods included
   - Verification logic template
   - Extensive comments and examples

2. **`theme-metadata.txt`**
   - Theme metadata template
   - All fields documented
   - Example values
   - Required files checklist

3. **`README.md`** (in `.templates/`)
   - Quick start guide for templates
   - Usage instructions
   - Examples

### 📖 **Updated Main README**
   - New "Customization & Extensions" section
   - Links to extension documentation
   - Quick examples
   - Invitation to contribute

---

## Extension Format v1.0

### Application Extension

```bash
#!/bin/bash
# BENTOBOX_EXTENSION: v1
# NAME: App Name - Short Description
# DESCRIPTION: Detailed description
# CATEGORY: Communication
# ICON: app-icon
# HOMEPAGE: https://app.com
# CHECK_COMMAND: app-command
# REQUIRES: dependencies
# CONFLICTS: conflicting-apps
# AUTHOR: Your Name
# VERSION: 1.0

# Check if installed
if command -v app &> /dev/null; then
    echo "✓ Already installed, skipping..."
    exit 0
fi

# Install
echo "📦 Installing..."
sudo snap install app

# Verify
if command -v app &> /dev/null; then
    echo "✅ Success"
    exit 0
else
    echo "❌ Failed"
    exit 1
fi
```

### Theme Extension

```
themes/your-theme/
├── metadata.txt          # Theme info
├── gnome.sh             # GNOME settings
├── alacritty.toml       # Terminal colors
├── zellij.kdl           # Multiplexer theme
├── btop.theme           # System monitor
├── neovim.lua           # Editor theme
├── vscode.sh            # VS Code theme
└── background.jpg       # Wallpaper
```

---

## How It Works

### Auto-Discovery

1. **Backend (Orchestrator)** ✅ Already Working
   ```python
   def discover_components(self):
       # Scans directories
       for script in terminal_dir.glob('*.sh'):
           # Auto-registers component
   ```

2. **Frontend (GUI/TUI)** ⚠️ Needs Implementation
   ```python
   # Currently hardcoded (needs fixing):
   apps = [
       ("cursor", "Cursor"),
       ("chrome", "Chrome"),
   ]
   
   # Should be (recommended):
   def discover_available_apps(self):
       apps = []
       for script in optional_dir.glob('app-*.sh'):
           metadata = read_metadata(script)
           apps.append((metadata['id'], metadata['name']))
       return apps
   ```

### User Experience

**Adding Slack (after frontend improvements):**

1. Create `app-slack.sh` with metadata
2. Done! ✅

Slack automatically appears in:
- ✅ Orchestrator (already working)
- ⚠️ GUI (needs implementation)
- ⚠️ TUI menu (needs implementation)

---

## Categories

### Standard Application Categories

- **Communication** - Slack, Discord, Teams
- **Development** - IDEs, editors, Git tools
- **Graphics** - GIMP, Inkscape, Blender
- **Productivity** - Office, notes, planning
- **Media** - VLC, OBS, Audacity
- **Utilities** - File managers, system tools
- **Gaming** - Steam, Lutris
- **Security** - Password managers, VPNs
- **Education** - Learning platforms
- **Internet** - Browsers, downloaders

---

## Examples

### Example 1: Slack

```bash
#!/bin/bash
# BENTOBOX_EXTENSION: v1
# NAME: Slack - Team Communication
# DESCRIPTION: Messaging and collaboration platform
# CATEGORY: Communication
# HOMEPAGE: https://slack.com
# CHECK_COMMAND: slack

if command -v slack &> /dev/null; then
    echo "✓ Slack already installed, skipping..."
    exit 0
fi

echo "📦 Installing Slack..."
sudo snap install slack --classic

if command -v slack &> /dev/null; then
    echo "✅ Slack installed successfully"
    exit 0
else
    echo "❌ Slack installation failed"
    exit 1
fi
```

### Example 2: Dracula Theme

```
themes/dracula/
├── metadata.txt
    NAME: Dracula
    DESCRIPTION: Dark theme for the masses
    COLORS: purple, pink, cyan
    STYLE: dark
    
├── gnome.sh
    OMAKUB_THEME_COLOR="purple"
    OMAKUB_THEME_BACKGROUND="dracula/background.jpg"
    
├── alacritty.toml (with Dracula colors)
├── zellij.kdl (with Dracula colors)
├── btop.theme (with Dracula colors)
├── neovim.lua (Dracula plugin)
├── vscode.sh (Dracula extension)
└── background.jpg
```

---

## Benefits

### For Users

- ✅ **Easy Installation** - One command to add new apps
- ✅ **No Code Editing** - Just copy template and fill in
- ✅ **Auto-Integration** - Apps appear in GUI automatically
- ✅ **Consistent Format** - All extensions work the same way

### For Developers

- ✅ **Simple Standard** - Clear metadata format
- ✅ **Flexible** - Supports any installation method
- ✅ **Well-Documented** - Extensive guides and examples
- ✅ **Community-Friendly** - Easy to contribute

### For Project

- ✅ **Extensible** - Community can add packages
- ✅ **Maintainable** - Standardized format
- ✅ **Scalable** - No core code changes needed
- ✅ **Professional** - Clean, documented system

---

## Next Steps (Recommended)

### Phase 1: Dynamic GUI Discovery (High Priority)

**Effort:** 8-12 hours
**Impact:** Makes system fully extensible

1. Modify `install/gui.py`:
   ```python
   def discover_available_apps(self):
       """Read metadata from scripts"""
       apps = []
       for script in optional_dir.glob('app-*.sh'):
           metadata = self._read_script_metadata(script)
           if metadata:
               apps.append((
                   metadata['id'],
                   metadata.get('NAME', script.stem)
               ))
       return sorted(apps, key=lambda x: x[1])
   
   def _read_script_metadata(self, script_path):
       """Parse metadata from script comments"""
       metadata = {}
       with open(script_path) as f:
           for line in f:
               if line.startswith('# NAME:'):
                   metadata['NAME'] = line.split(':', 1)[1].strip()
               elif line.startswith('# CATEGORY:'):
                   metadata['CATEGORY'] = line.split(':', 1)[1].strip()
               # ... etc
       return metadata
   ```

2. Update `build_selection_tab()` to use discovered apps
3. Remove hardcoded lists

**Result:** Drop in new script → appears in GUI automatically

### Phase 2: Dynamic TUI Menu (Medium Priority)

**Effort:** 4-6 hours
**Impact:** Terminal users benefit too

1. Modify `install/pre-installation-menu.sh` to scan directory
2. Read metadata from scripts
3. Build menu dynamically

**Result:** Menu updates automatically with new scripts

### Phase 3: Theme Auto-Discovery (Medium Priority)

**Effort:** 4-6 hours
**Impact:** Theme creators benefit

1. Add `metadata.txt` to all existing themes
2. Update GUI to scan themes directory
3. Read metadata for display names

**Result:** Drop in new theme → appears in GUI automatically

---

## Testing

### Validation Checklist

- [ ] Metadata block is complete
- [ ] Script checks if already installed
- [ ] Installation is idempotent
- [ ] Clear success/failure messages
- [ ] Exit code 0 for success
- [ ] Executable permissions set
- [ ] Dependencies documented
- [ ] Tested on fresh Ubuntu 24.04

### Testing Commands

```bash
# Syntax check
bash -n install/desktop/optional/app-yourapp.sh

# Test installation
bash install/desktop/optional/app-yourapp.sh

# Test idempotency
bash install/desktop/optional/app-yourapp.sh

# Verify discovery
python3 install/orchestrator.py --list-components

# Test in GUI
./bentobox-gui.sh
```

---

## Contributing

### For Extension Creators

1. Use the templates in `.templates/`
2. Follow the format specification
3. Test thoroughly
4. Submit pull request with:
   - Extension description
   - Screenshots (if GUI app)
   - Testing notes
   - Checklist from spec

### For Core Contributors

If implementing dynamic discovery:
1. Start with Phase 1 (GUI discovery)
2. Test extensively
3. Update documentation
4. Add example extensions

---

## Documentation Files

| File | Purpose | Size |
|------|---------|------|
| `EXTENSION_FORMAT_SPEC.md` | Technical specification | 6,000+ words |
| `EXTENSION_DEVELOPER_GUIDE.md` | Developer tutorial | 4,500+ words |
| `EXTENSIBILITY_ANALYSIS.md` | Current state analysis | 3,800+ words |
| `.templates/app-template.sh` | Application template | 150 lines |
| `.templates/theme-metadata.txt` | Theme template | 60 lines |
| `.templates/README.md` | Template usage guide | 100 lines |

**Total documentation:** ~14,000 words + templates

---

## Summary

### What's Working Now ✅

- ✅ Backend auto-discovers installation scripts
- ✅ Scripts execute independently
- ✅ State management tracks all components
- ✅ Templates ready for community use
- ✅ Comprehensive documentation
- ✅ Standard format defined

### What Needs Work ⚠️

- ⚠️ GUI has hardcoded app lists (needs Phase 1)
- ⚠️ TUI menu has hardcoded lists (needs Phase 2)
- ⚠️ Theme selection is hardcoded (needs Phase 3)

### End Goal 🎯

```
DROP IN NEW FILE → APPEARS IN GUI AUTOMATICALLY
```

**To add Slack:**
1. Copy `app-template.sh` to `app-slack.sh`
2. Fill in metadata
3. Done! ✅

No code editing. No core changes. Just works.

---

## Success Criteria

Extension system is complete when:

✅ Documentation is comprehensive
✅ Templates are available
✅ Standard format is defined
✅ Backend auto-discovers extensions
⚠️ Frontend dynamically discovers extensions (needs implementation)
⚠️ No hardcoded lists in GUI/TUI (needs implementation)
✅ Community can contribute easily
✅ Examples are provided

**Current status: 5/8 complete (62%)**

**With Phase 1-3 implemented: 8/8 complete (100%)**

---

## Final Notes

The extension system is **architecturally ready** and **well-documented**. The metadata format is defined, templates are available, and the backend already supports auto-discovery.

The remaining work is frontend implementation (Phases 1-3) to make the GUI and TUI read from the filesystem instead of hardcoded lists.

**This makes Bentobox a true community-extensible platform!** 🚀

---

## Quick Reference

### Add Application
```bash
cp .templates/app-template.sh install/desktop/optional/app-{name}.sh
# Edit, make executable, done!
```

### Add Theme
```bash
mkdir themes/{name}
cp .templates/theme-metadata.txt themes/{name}/metadata.txt
# Add theme files, done!
```

### Test Extension
```bash
bash install/desktop/optional/app-{name}.sh
python3 install/orchestrator.py --list-components
```

### Contribute
```bash
git add install/desktop/optional/app-{name}.sh
git commit -m "Add {Name} extension"
# Open pull request
```

---

**The extension system is ready for the community!** 🎉

