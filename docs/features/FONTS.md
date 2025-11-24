# Terminal Font Spacing Issue - Fix Guide

## Problem

The terminal fonts appear "too widely spaced" on leaf after installation.

## Root Cause

The issue is likely caused by:
1. Using "CaskaydiaMono Nerd Font" instead of "CaskaydiaMono Nerd Font **Mono**"
2. Terminal cell spacing not configured
3. Font size too small or large
4. Terminal not using the configured font

## Quick Fix (Run from Desktop)

### Option 1: Run the fix script

```bash
# From GNOME Terminal on leaf desktop:
bash ~/.local/share/omakub/fix-terminal-fonts.sh
```

This will:
- Switch to "Nerd Font Mono" variant (better spacing)
- Set font size to 11
- Configure terminal cell spacing
- Refresh font cache

Then **close and reopen terminal** to see changes.

### Option 2: Manual fix via GUI

1. Open **GNOME Terminal**
2. Go to **Preferences**
3. Select your profile
4. Uncheck "Use system font"
5. Click **Custom font**
6. Select: **CaskaydiaMono Nerd Font Mono**
7. Size: **11**
8. Close preferences
9. Restart terminal

### Option 3: Command line fix

```bash
# Get your profile ID
PROFILE=$(gsettings get org.gnome.Terminal.ProfilesList default | tr -d "'")

# Set the correct font
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$PROFILE/ font 'CaskaydiaMono Nerd Font Mono 11'

# Disable system font
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$PROFILE/ use-system-font false

# Set proper spacing
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$PROFILE/ cell-height-scale 1.0
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$PROFILE/ cell-width-scale 1.0
```

## Understanding the Font Names

There are multiple Cascadia variants installed:

1. **CaskaydiaMono Nerd Font** - Variable width (causes spacing issues)
2. **CaskaydiaMono Nerd Font Mono** - Fixed width (✅ USE THIS ONE)
3. **CaskaydiaMono Nerd Font Propo** - Proportional

For terminals, **always use the "Mono" variant** for consistent character spacing.

## Verify Font is Installed

```bash
fc-list | grep -i caskaydia
```

Should show many CaskaydiaMono variants installed.

## Check Current Terminal Font

```bash
# System-wide monospace font
gsettings get org.gnome.desktop.interface monospace-font-name

# Terminal profile font
PROFILE=$(gsettings get org.gnome.Terminal.ProfilesList default | tr -d "'")
gsettings get org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$PROFILE/ font
```

## Test Different Fonts

If CaskaydiaMono still doesn't look right, try:

### iA Writer Mono (also installed)

```bash
PROFILE=$(gsettings get org.gnome.Terminal.ProfilesList default | tr -d "'")
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$PROFILE/ font 'iA Writer Mono S 11'
```

### JetBrains Mono (if installed)

```bash
sudo apt install fonts-jetbrains-mono
PROFILE=$(gsettings get org.gnome.Terminal.ProfilesList default | tr -d "'")
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$PROFILE/ font 'JetBrains Mono 11'
```

### Fira Code (if installed)

```bash
sudo apt install fonts-firacode
PROFILE=$(gsettings get org.gnome.Terminal.ProfilesList default | tr -d "'")
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$PROFILE/ font 'Fira Code 11'
```

## Adjust Font Size

If spacing is OK but size is wrong:

```bash
# Larger
PROFILE=$(gsettings get org.gnome.Terminal.ProfilesList default | tr -d "'")
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$PROFILE/ font 'CaskaydiaMono Nerd Font Mono 12'

# Smaller
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$PROFILE/ font 'CaskaydiaMono Nerd Font Mono 10'
```

## For Alacritty Users

If you're using Alacritty instead of GNOME Terminal:

```bash
# Edit config
nano ~/.config/alacritty/font.toml
```

Change to:
```toml
[font]
normal = { family = "CaskaydiaMono Nerd Font Mono", style = "Regular" }
bold = { family = "CaskaydiaMono Nerd Font Mono", style = "Bold" }
italic = { family = "CaskaydiaMono Nerd Font Mono", style = "Italic" }

[font]
size = 11.0
```

## Reset to System Default

If you want to go back to Ubuntu's default:

```bash
PROFILE=$(gsettings get org.gnome.Terminal.ProfilesList default | tr -d "'")
gsettings reset org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$PROFILE/ font
gsettings reset org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$PROFILE/ use-system-font
```

## Prevention for Future

The orchestrator now includes automatic font configuration:

```bash
# Re-run post-installation
cd ~/.local/share/omakub
python3 install/orchestrator.py
```

Or from the GUI:
1. Open **bentobox-gui**
2. Go to **🎨 Desktop** tab
3. Click **📝 Install Fonts Now**

This will properly configure fonts automatically.

## Still Having Issues?

### Check for font conflicts

```bash
# See all installed monospace fonts
fc-list :spacing=mono family | sort | uniq
```

### Clear font cache completely

```bash
rm -rf ~/.cache/fontconfig
fc-cache -fv
```

### Restart GNOME Shell

Press **Alt+F2**, type `r`, press Enter

Or log out and back in.

## Summary

**Quick fix for leaf:**
```bash
# Run from desktop terminal:
bash ~/.local/share/omakub/fix-terminal-fonts.sh
# Then close and reopen terminal
```

The key is using "**CaskaydiaMono Nerd Font Mono**" (with "Mono" at the end) at size 11 for proper character spacing in terminals.

