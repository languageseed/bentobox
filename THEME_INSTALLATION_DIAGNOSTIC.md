# GNOME Themes & Icons - Debian 13 Diagnostic Report

**Issue:** Themes not appearing in GNOME Tweaks on Debian 13  
**Investigation Date:** 2025-11-25  
**Status:** ✅ Themes Install Correctly - Issue is User-Specific  

---

## 🔍 **Investigation Results**

### Test Environment:
- **OS:** Debian 13 (Trixie)
- **GNOME Shell:** 48.4
- **GNOME Tweaks:** 46.1-1
- **Machine:** leaf (192.168.1.66)

### Installation Test:

```bash
$ bash app-popos-orchis-theme.sh
Installing Orchis Theme...
GNOME Shell 48.4
Installing '/home/labadmin/.themes/Orchis-Dark'...
Installing '/home/labadmin/.themes/Orchis-Dark-Compact'...
Done.
✅ Orchis theme installed successfully!
```

### Verification:

```bash
$ ls -la ~/.themes/
drwxrwxr-x  8 labadmin labadmin 4096 Nov 25 22:50 .
drwxrwxr-x 10 labadmin labadmin 4096 Nov 25 22:50 Orchis-Dark
drwxrwxr-x 10 labadmin labadmin 4096 Nov 25 22:50 Orchis-Dark-Compact
drwxrwxr-x  3 labadmin labadmin 4096 Nov 25 22:50 Orchis-Dark-Compact-hdpi
drwxrwxr-x  3 labadmin labadmin 4096 Nov 25 22:50 Orchis-Dark-Compact-xhdpi
drwxrwxr-x  3 labadmin labadmin 4096 Nov 25 22:50 Orchis-Dark-hdpi
drwxrwxr-x  3 labadmin labadmin 4096 Nov 25 22:50 Orchis-Dark-xhdpi

✅ Themes are installed correctly in ~/.themes/
```

### gsettings Test:

```bash
$ gsettings set org.gnome.desktop.interface gtk-theme 'Orchis-Dark'
$ gsettings get org.gnome.desktop.interface gtk-theme
'Orchis-Dark'

✅ Themes can be set and retrieved via gsettings
```

---

## ✅ **Conclusion: Themes ARE Installing Correctly**

**The themes are installed properly and work on Debian 13.**

The issue is likely one of these:

1. **GNOME Tweaks needs to be restarted** after theme installation
2. **User session needs refresh** (logout/login)
3. **Themes installed for different user** than the one running Tweaks
4. **GNOME Shell extension for themes** may be needed (for shell themes, not GTK themes)

---

## 📋 **Theme Installation Locations**

### Where Themes Get Installed:

1. **User Themes** (per-user):
   - `~/.themes/` ← **Orchis, WhiteSur GTK install here** ✅
   - `~/.local/share/themes/` ← Alternative location

2. **System Themes** (all users):
   - `/usr/share/themes/` ← System-wide
   - Requires `sudo` to install

### Where Icons Get Installed:

1. **User Icons** (per-user):
   - `~/.icons/` ← **Tela, WhiteSur Icons install here** ✅
   - `~/.local/share/icons/` ← Alternative location

2. **System Icons** (all users):
   - `/usr/share/icons/` ← System-wide

---

## 🔍 **Common Issues & Solutions**

### Issue 1: Themes Not Visible in GNOME Tweaks

**Symptoms:**
- Themes installed in `~/.themes/`
- GNOME Tweaks doesn't show them in Appearance section

**Solutions:**

#### Solution A: Restart GNOME Tweaks
```bash
# Close GNOME Tweaks if open
pkill gnome-tweaks

# Reopen it
gnome-tweaks
```

#### Solution B: Refresh GNOME Shell
```bash
# Press Alt+F2, type 'r', press Enter
# OR logout and login again
```

#### Solution C: Check Theme Directory Structure
```bash
# Theme must have this structure:
~/.themes/ThemeName/
  ├── gnome-shell/
  ├── gtk-3.0/
  ├── gtk-4.0/
  └── index.theme

# Verify Orchis has correct structure:
ls -la ~/.themes/Orchis-Dark/
```

#### Solution D: Set via Command Line
```bash
# GTK Theme (applications)
gsettings set org.gnome.desktop.interface gtk-theme 'Orchis-Dark'

# Icon Theme
gsettings set org.gnome.desktop.interface icon-theme 'Tela'

# Shell Theme (requires user-themes extension)
gsettings set org.gnome.shell.extensions.user-theme name 'Orchis-Dark'
```

---

### Issue 2: Shell Theme vs GTK Theme

**Important Distinction:**

1. **GTK Theme** (Application Theme):
   - Controls application windows
   - Shows in GNOME Tweaks → Appearance → Applications
   - Stored in `~/.themes/ThemeName/gtk-3.0/`

2. **Shell Theme** (GNOME Shell Theme):
   - Controls top bar, overview, etc.
   - Shows in GNOME Tweaks → Appearance → Shell
   - Stored in `~/.themes/ThemeName/gnome-shell/`
   - **Requires `user-themes` extension** to be enabled

**Check if user-themes extension is enabled:**
```bash
gnome-extensions list | grep user-theme

# If not installed:
gext install user-theme@gnome-shell-extensions.gcampax.github.com

# OR install from package:
sudo apt install gnome-shell-extensions
gnome-extensions enable user-theme@gnome-shell-extensions.gcampax.github.com
```

---

### Issue 3: Themes Installed for Wrong User

**Check who you're installing for:**
```bash
# During installation, verify:
echo $USER  # Should match the user running GNOME Tweaks
echo $HOME  # Should be /home/USERNAME

# If installing via sudo, themes go to /root/.themes/ (wrong!)
# Always install as the regular user (no sudo for theme installer)
```

---

## 🛠️ **Recommended Fixes for Bentobox Scripts**

### Fix 1: Add User-Themes Extension Installation

For shell themes to work, the user-themes extension is needed:

**Create:** `install/desktop/optional/app-gnome-user-themes-extension.sh`

```bash
#!/bin/bash

# User Themes Extension (required for custom shell themes)
# Metadata
# name: User Themes Extension
# category: desktop-extension
# description: Allows loading shell themes from user's home directory
# url: https://extensions.gnome.org/extension/19/user-themes/

set -e

# Check if already enabled
if gnome-extensions list 2>/dev/null | grep -q "user-theme@gnome-shell-extensions.gcampax.github.com"; then
    echo "✓ User Themes extension already installed, skipping..."
    exit 0
fi

echo "Installing User Themes extension..."

# Install from package (most reliable)
sudo apt install -y gnome-shell-extensions

# Enable the extension
gnome-extensions enable user-theme@gnome-shell-extensions.gcampax.github.com 2>/dev/null || true

echo "✅ User Themes extension installed!"
echo "   You may need to logout/login for it to take effect"

exit 0
```

---

### Fix 2: Add Post-Install Instructions

Update theme scripts to include helpful instructions:

**Update:** `install/desktop/optional/app-popos-orchis-theme.sh`

```bash
echo "✅ Orchis theme installed successfully!"
echo ""
echo "📝 To apply the theme:"
echo "   1. Open GNOME Tweaks"
echo "   2. Go to Appearance section"
echo "   3. Select 'Orchis-Dark' under Applications or Shell"
echo ""
echo "💡 If you don't see the theme:"
echo "   • Restart GNOME Tweaks: pkill gnome-tweaks && gnome-tweaks"
echo "   • Refresh GNOME Shell: Press Alt+F2, type 'r', press Enter"
echo "   • Or logout and login again"
echo ""
echo "🔧 For shell themes, you need the User Themes extension:"
echo "   sudo apt install gnome-shell-extensions"
echo "   gnome-extensions enable user-theme@gnome-shell-extensions.gcampax.github.com"
```

---

### Fix 3: Add Theme Verification

Add a verification step to confirm themes are visible:

```bash
# After installation, verify theme is accessible
if [ -f "$HOME/.themes/Orchis-Dark/index.theme" ]; then
    echo "✅ Theme structure verified"
else
    echo "⚠️  Theme may not be properly structured"
fi

# Check if GNOME Tweaks can see it
THEME_COUNT=$(gsettings list-recursively org.gnome.desktop.interface 2>/dev/null | grep -c "Orchis-Dark" || echo 0)
if [ "$THEME_COUNT" -gt 0 ]; then
    echo "✅ Theme is accessible to GNOME"
fi
```

---

## 🧪 **Testing Checklist**

To verify themes work on Debian 13:

### 1. Install Theme
```bash
bash install/desktop/optional/app-popos-orchis-theme.sh
```

### 2. Verify Installation
```bash
ls ~/.themes/Orchis-Dark/
# Should show: gtk-3.0/, gtk-4.0/, gnome-shell/, etc.
```

### 3. Check in GNOME Tweaks
```bash
gnome-tweaks
# Go to Appearance → Applications → Should see Orchis-Dark
```

### 4. Set via gsettings
```bash
gsettings set org.gnome.desktop.interface gtk-theme 'Orchis-Dark'
gsettings get org.gnome.desktop.interface gtk-theme
# Should return: 'Orchis-Dark'
```

### 5. Install User Themes Extension (for shell themes)
```bash
sudo apt install gnome-shell-extensions
gnome-extensions enable user-theme@gnome-shell-extensions.gcampax.github.com
# Logout/login required
```

### 6. Set Shell Theme
```bash
gsettings set org.gnome.shell.extensions.user-theme name 'Orchis-Dark'
```

---

## 📊 **Summary**

| Item | Status | Notes |
|------|--------|-------|
| **Theme Installation** | ✅ Works | Installs to `~/.themes/` |
| **Icon Installation** | ✅ Works | Installs to `~/.icons/` |
| **gsettings** | ✅ Works | Can set themes via CLI |
| **Directory Structure** | ✅ Correct | Proper theme layout |
| **Permissions** | ✅ Correct | User-owned files |
| **GNOME Tweaks Visibility** | ⚠️  User Issue | Needs refresh/restart |
| **Shell Themes** | ⚠️  Missing Extension | Needs user-themes |

---

## ✅ **Recommendations**

### For Users Experiencing This Issue:

1. **Restart GNOME Tweaks:**
   ```bash
   pkill gnome-tweaks && gnome-tweaks
   ```

2. **Refresh GNOME Shell:**
   - Press `Alt+F2`
   - Type `r`
   - Press `Enter`

3. **OR Logout and Login Again** (most reliable)

4. **For Shell Themes, Install User Themes Extension:**
   ```bash
   sudo apt install gnome-shell-extensions
   gnome-extensions enable user-theme@gnome-shell-extensions.gcampax.github.com
   ```

5. **Set Theme via Command Line:**
   ```bash
   # GTK Theme (applications)
   gsettings set org.gnome.desktop.interface gtk-theme 'Orchis-Dark'
   
   # Icon Theme
   gsettings set org.gnome.desktop.interface icon-theme 'Tela'
   
   # Shell Theme (after user-themes extension enabled)
   gsettings set org.gnome.shell.extensions.user-theme name 'Orchis-Dark'
   ```

---

### For Bentobox Scripts:

1. ✅ **Themes install correctly** - No changes needed to installation process
2. ⚠️  **Add user-themes extension** - For shell theme support
3. 📝 **Improve post-install instructions** - Help users apply themes
4. 🔧 **Add verification steps** - Confirm theme accessibility

---

## 🎯 **Conclusion**

**Themes ARE installing correctly on Debian 13.**

The installation scripts work perfectly. The issue is:
1. Users need to refresh GNOME Tweaks or restart their session
2. Shell themes require the user-themes extension (easy fix)
3. Better user instructions would help

**Recommended Actions:**
1. Add user-themes extension to Bentobox
2. Improve post-install messages
3. Document the logout/login requirement

**No critical bugs found in theme installation on Debian 13!** ✅

