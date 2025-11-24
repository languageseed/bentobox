# Bentobox GUI - Themes & Fonts Support

## What's New

The Bentobox GUI and orchestrator now automatically handle themes and fonts installation!

### Features Added

1. **Automatic Fonts Installation**
   - Cascadia Mono (Nerd Font)
   - iA Writer Mono
   - Installed to `~/.local/share/fonts`
   - Font cache refreshed automatically

2. **Automatic Theme Application**
   - Tokyo Night GNOME theme
   - Custom wallpaper
   - GNOME settings (dock, extensions, etc.)

3. **Manual Theme Button in GUI**
   - "🎨 Apply Themes & Fonts" button
   - Run anytime to reapply customizations
   - No need to reinstall packages

## How It Works

### During Installation

When you run the installation (via GUI or CLI), it now automatically:

1. Installs all selected components (apps, languages, containers)
2. **NEW**: Downloads and installs fonts
3. **NEW**: Applies GNOME theme and wallpaper
4. **NEW**: Configures GNOME settings

### Manual Application

If you want to apply themes without reinstalling everything:

**From GUI:**
1. Launch `bentobox-gui`
2. Click "🎨 Apply Themes & Fonts" button
3. Confirm the action
4. Wait for completion
5. Log out and back in

**From Command Line:**
```bash
# Fonts
bash ~/.local/share/omakub/install/desktop/fonts.sh

# Theme
export OMAKUB_PATH=~/.local/share/omakub
bash $OMAKUB_PATH/install/desktop/set-gnome-theme.sh

# Settings
bash $OMAKUB_PATH/install/desktop/set-gnome-settings.sh
```

## What Gets Installed

### Fonts

**Cascadia Mono (Nerd Font)**
- Modern monospace font
- Programming ligatures
- Nerd Font icons
- Source: https://github.com/ryanoasis/nerd-fonts

**iA Writer Mono**
- Clean, minimal monospace
- Great for writing and coding
- Source: https://github.com/iaolo/iA-Fonts

### Theme

**Tokyo Night**
- Dark theme optimized for long coding sessions
- Easy on the eyes
- Consistent colors across terminal and desktop

**Custom Wallpaper**
- Beautiful nature photography
- Complements the Tokyo Night theme

### GNOME Settings

- Dock configuration
- Keyboard shortcuts
- Window management
- Extensions (if in desktop session)

## Requirements

### For Automatic Application

The orchestrator detects if you're in a desktop session:

**Desktop Session** (DISPLAY or WAYLAND_DISPLAY set):
- ✅ Fonts installed
- ✅ Theme applied
- ✅ Settings configured

**No Desktop Session** (SSH, no display):
- ✅ Packages installed
- ⏭️ Themes/fonts skipped
- 📝 Instructions printed for manual completion

### Running from Desktop

If you ran the installation over SSH, you can apply themes later:

1. Log into GNOME desktop
2. Open terminal (Ctrl+Alt+T)
3. Run: `bentobox-gui`
4. Click "🎨 Apply Themes & Fonts"

## Testing

### Test Command-Line Install

```bash
cd ~/.local/share/omakub
python3 install/orchestrator.py
```

Output will show:
```
🎨 Post-Installation Setup
==================================================

📝 Installing fonts...
  ✅ Fonts installed

🎨 Applying GNOME theme...
  ✅ Theme applied

⚙️  Applying GNOME settings...
  ✅ Settings applied

✨ Post-installation setup complete!
```

### Test GUI

```bash
bentobox-gui
```

1. Select components
2. Click "🚀 Start Installation"
3. Watch terminal output
4. See fonts/themes applied automatically
5. OR click "🎨 Apply Themes & Fonts" separately

## Troubleshooting

### Fonts Don't Show Up

**Symptom:** Fonts installed but not visible in applications

**Solution:**
```bash
fc-cache -fv
```

Then restart the application.

### Theme Not Applied

**Symptom:** Theme scripts run but appearance unchanged

**Check if in desktop session:**
```bash
echo "DISPLAY: $DISPLAY"
echo "WAYLAND_DISPLAY: $WAYLAND_DISPLAY"
```

Both empty = not in desktop session.

**Solution:** Log out and back in, or run from desktop terminal.

### Wallpaper Missing

**Check if wallpaper exists:**
```bash
ls -la ~/.local/share/omakub/wallpaper/
```

**Reapply:**
```bash
export OMAKUB_PATH=~/.local/share/omakub
bash $OMAKUB_PATH/install/desktop/set-wallpaper.sh
```

### Extensions Not Working

GNOME extensions require:
1. Desktop session (not SSH)
2. User approval (browser popups)
3. GNOME Shell restart (Alt+F2, type 'r', Enter)

**Manual installation:**
```bash
# From desktop terminal
bash ~/.local/share/omakub/install/desktop/set-gnome-extensions.sh
```

## Files Modified

### Orchestrator (`install/orchestrator.py`)
- Added `run_post_install()` method
- Calls fonts, theme, and settings scripts
- Detects desktop session
- Runs after component installation

### GUI (`install/gui.py`)
- Added "🎨 Apply Themes & Fonts" button
- Added `on_apply_themes()` handler
- Added `apply_themes_worker()` background thread
- Added completion dialogs

### Scripts Used
- `install/desktop/fonts.sh` - Downloads and installs fonts
- `install/desktop/set-gnome-theme.sh` - Applies Tokyo Night theme
- `install/desktop/set-gnome-settings.sh` - Configures GNOME
- `install/desktop/set-wallpaper.sh` - Sets custom wallpaper

## What's Next

Themes and fonts are now integrated! After installation:

1. **Immediate**: Fonts available in terminal
2. **After logout**: Theme fully applied
3. **Extensions**: May need manual approval via browser

Enjoy your beautiful new desktop! 🎨✨

