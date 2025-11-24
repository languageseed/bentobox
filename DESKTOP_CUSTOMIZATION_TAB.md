# Bentobox GUI - Desktop Customization Tab

## Overview

The new **🎨 Desktop** tab provides a comprehensive interface for customizing your Ubuntu desktop appearance and behavior.

## Features

### 1. Theme Selection

**Choose from available themes:**
- Tokyo Night (default)
- Catppuccin
- Everforest
- Gruvbox
- Kanagawa
- Matte Black
- Nord
- Osaka Jade
- Ristretto
- Rose Pine

**How it works:**
- Radio button selection (only one theme active)
- Theme is applied during installation or via "Apply Theme Now" button
- Includes matching colors for:
  - Terminal
  - GNOME Shell
  - Applications
  - Wallpaper

### 2. Fonts

**Cascadia Mono (Nerd Font)**
- Modern programming font
- Includes ligatures
- Nerd Font icons for terminal
- ~70MB download

**iA Writer Mono**
- Clean, minimal monospace
- Great for writing and coding
- ~5MB download

**Options:**
- ✅ Install Cascadia Mono
- ✅ Install iA Writer Mono
- Both enabled by default

### 3. Wallpaper

**Custom Wallpaper:**
- High-quality nature photography
- Matches selected theme
- Stored in `~/.local/share/omakub/wallpaper/`

**Options:**
- ✅ Set custom wallpaper (enabled by default)
- Previews show how many wallpapers are available

### 4. GNOME Configuration

**GNOME Settings:**
- Dock position and behavior
- Window management
- Application menu
- Favorites bar

**Keyboard Shortcuts:**
- Custom hotkeys for common actions
- Terminal shortcuts
- Window management keys

**GNOME Extensions:**
- Optional (disabled by default)
- Requires browser approval popups
- Enhances desktop functionality
- Only works from desktop session (not SSH)

### 5. Quick Actions

**Three instant buttons:**

**🎨 Apply Theme Now**
- Applies currently selected theme
- Installs fonts if selected
- Sets wallpaper
- Configures GNOME
- Runs in background thread
- Shows completion dialog

**📝 Install Fonts Now**
- Downloads and installs fonts only
- No theme changes
- Fast operation (~2-3 minutes)
- Useful if fonts weren't installed initially

**🔄 Reset to Defaults**
- Restores all default selections:
  - Theme: Tokyo Night
  - All fonts: Enabled
  - All GNOME settings: Enabled
  - Extensions: Disabled
- Confirmation required

## Usage

### During Installation

1. Open **bentobox-gui**
2. Go to **🎨 Desktop** tab
3. Select your preferences:
   - Pick a theme
   - Choose fonts
   - Toggle wallpaper
   - Enable/disable GNOME features
4. Go to **📦 Components** tab and select apps
5. Click **💾 Save Configuration**
6. Go to **▶️  Install** tab
7. Click **🚀 Start Installation**

Everything will be applied automatically!

### Apply Changes Later

If you want to change your desktop appearance after installation:

1. Open **bentobox-gui**
2. Go to **🎨 Desktop** tab
3. Change theme or other settings
4. Click **💾 Save Configuration**
5. Click **🎨 Apply Theme Now**

No need to reinstall anything!

### Fonts Only

To install/reinstall just fonts:

1. Open **bentobox-gui**
2. Go to **🎨 Desktop** tab
3. Check desired fonts
4. Click **📝 Install Fonts Now**

## Configuration File

Settings are saved to `~/.bentobox-config.yaml`:

```yaml
desktop:
  optional_apps:
    - cursor
    - tailscale
  theme: tokyo-night
  install_fonts: true
  install_ia_fonts: true
  set_wallpaper: true
  apply_gnome_settings: true
  apply_hotkeys: true
  install_extensions: false
```

## Theme Details

### Tokyo Night
- Dark blue theme
- Soft on eyes
- Great for coding
- Default choice

### Catppuccin
- Pastel colors
- Multiple variants
- Modern aesthetic

### Everforest
- Green/brown palette
- Nature-inspired
- Easy on eyes

### Gruvbox
- Retro colors
- High contrast
- Popular classic

### Nord
- Arctic-inspired
- Cool blues
- Minimal

### Rose Pine
- Muted pastels
- Elegant
- Low contrast

### And more...
Each theme includes:
- Terminal colors
- Shell theme
- Matching wallpaper
- Coordinated UI

## Recommended Settings

### For Developers
```
Theme: Tokyo Night or Gruvbox
Fonts: Both enabled
GNOME Settings: Enabled
Hotkeys: Enabled
Extensions: Optional
```

### For Designers
```
Theme: Catppuccin or Rose Pine
Fonts: iA Writer Mono
GNOME Settings: Enabled
Hotkeys: Enabled
Extensions: Enabled
```

### For Writers
```
Theme: Nord or Everforest
Fonts: iA Writer Mono only
GNOME Settings: Enabled
Hotkeys: Enabled
Extensions: Optional
```

### Minimal Setup
```
Theme: Any
Fonts: Cascadia Mono only
GNOME Settings: Enabled
Hotkeys: Disabled
Extensions: Disabled
```

## Troubleshooting

### Theme doesn't apply

**Check if in desktop session:**
```bash
echo $DISPLAY
echo $WAYLAND_DISPLAY
```

Both should have values. If empty, you're not in a graphical session.

**Solution:** Run from actual desktop, not SSH.

### Fonts not showing

**Refresh font cache:**
```bash
fc-cache -fv
```

**Restart applications** to pick up new fonts.

### Extensions don't install

Extensions require:
1. Desktop session (not SSH)
2. Browser approval
3. GNOME Shell restart

**Manual installation:**
```bash
bash ~/.local/share/omakub/install/desktop/set-gnome-extensions.sh
```

### Wallpaper not set

**Check if wallpapers exist:**
```bash
ls ~/.local/share/omakub/wallpaper/
```

**Manually set:**
```bash
export OMAKUB_PATH=~/.local/share/omakub
bash $OMAKUB_PATH/install/desktop/set-wallpaper.sh
```

## Advanced Usage

### Change Theme via Command Line

```bash
export OMAKUB_PATH=~/.local/share/omakub

# Apply specific theme
source $OMAKUB_PATH/themes/gruvbox/gnome.sh
source $OMAKUB_PATH/themes/gruvbox/tophat.sh
```

### Install Single Font

```bash
cd /tmp
wget https://github.com/ryanoasis/nerd-fonts/releases/latest/download/CascadiaMono.zip
unzip CascadiaMono.zip -d CascadiaFont
mkdir -p ~/.local/share/fonts
cp CascadiaFont/*.ttf ~/.local/share/fonts
fc-cache -fv
```

### Preview Themes

Themes are stored in:
```
~/.local/share/omakub/themes/
  ├── tokyo-night/
  │   ├── gnome.sh (shell theme)
  │   ├── tophat.sh (terminal)
  │   └── wallpaper.jpg
  ├── catppuccin/
  └── ...
```

Look at wallpaper.jpg to preview theme appearance.

## What Gets Applied

When you click "Apply Theme Now":

1. **Theme Colors**
   - GNOME Shell theme
   - Terminal color scheme
   - GTK theme (if available)

2. **Fonts** (if selected)
   - Downloads from GitHub
   - Installs to ~/.local/share/fonts
   - Updates font cache

3. **Wallpaper** (if selected)
   - Copies to system
   - Sets as desktop background
   - Sets as lock screen

4. **GNOME Settings** (if selected)
   - Dock configuration
   - Window behavior
   - Application settings

5. **Keyboard Shortcuts** (if selected)
   - Terminal hotkey
   - Window management
   - Custom shortcuts

6. **Extensions** (if selected)
   - Downloads from extensions.gnome.org
   - Requires browser popups
   - Needs GNOME Shell restart

## Tips

- **Try before committing**: Click "Apply Theme Now" to test themes without reinstalling
- **Save often**: Click "Save Configuration" after making changes
- **Fonts are big**: Cascadia Mono is 70MB, be patient during download
- **Extensions need approval**: Have your browser ready for popups
- **Log out to complete**: Some changes require logout/login
- **Reset if confused**: "Reset to Defaults" button restores sane settings

## Integration with Installation

The Desktop tab settings are automatically applied during full installation:

```
Installation Flow:
1. Install packages (apps, languages, containers)
2. Run post-installation:
   - Install selected fonts
   - Apply selected theme
   - Set wallpaper
   - Configure GNOME (if enabled)
   - Setup hotkeys (if enabled)
3. Extensions (if enabled and in desktop session)
4. Complete!
```

This means you can select everything once and run a complete installation without any manual steps!

## Summary

The Desktop Customization tab makes it easy to:
- ✅ Choose your favorite theme
- ✅ Select fonts that suit your work
- ✅ Control what gets configured
- ✅ Apply changes instantly
- ✅ Reset if things go wrong

All from a beautiful, easy-to-use interface! 🎨✨

