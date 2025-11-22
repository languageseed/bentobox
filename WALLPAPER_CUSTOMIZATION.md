# Wallpaper Customization Summary

## 🎨 Overview

Your custom Omakub fork now includes a curated collection of 7 wallpapers with automatic installation and setup.

---

## ✅ What Was Added

### Default Wallpaper Set:
⭐ **pexels-pok-rie-33563-2049422.jpg** - Mountain landscape with dramatic sky

### Additional Wallpapers Available:
1. pexels-eberhardgross-1062249.jpg
2. pexels-eberhardgross-443446.jpg
3. pexels-eberhardgross-640781.jpg
4. pexels-felix-mittermeier-956981.jpg
5. pexels-philippedonn-1169754.jpg
6. pexels-pok-rie-33563-982263.jpg

---

## 📁 Files Created/Modified

### Created:
1. ✅ **`install/desktop/set-wallpaper.sh`**
   - Copies all wallpapers from omakub/wallpaper/ to user's home
   - Sets default wallpaper automatically
   - Destination: `~/.local/share/backgrounds/omakub/`

2. ✅ **`wallpaper/README.md`**
   - Documents all available wallpapers
   - Instructions for changing wallpaper
   - How to add custom wallpapers

### Modified:
3. ✏️ **`install/desktop/set-gnome-theme.sh`**
   - Now calls custom wallpaper script
   - Overrides theme wallpaper with your custom choice

---

## 🚀 How It Works

### During Installation:

```
1. Desktop installation runs
   ↓
2. set-wallpaper.sh executes
   ↓
3. Creates directory: ~/.local/share/backgrounds/omakub/
   ↓
4. Copies all 7 wallpapers from installation
   ↓
5. Sets pexels-pok-rie-33563-2049422.jpg as default
   ↓
6. User sees custom wallpaper immediately after reboot
```

### Wallpaper Settings Applied:
```bash
# Light mode wallpaper
gsettings set org.gnome.desktop.background picture-uri "file://$HOME/.local/share/backgrounds/omakub/pexels-pok-rie-33563-2049422.jpg"

# Dark mode wallpaper (same image)
gsettings set org.gnome.desktop.background picture-uri-dark "file://$HOME/.local/share/backgrounds/omakub/pexels-pok-rie-33563-2049422.jpg"

# Display mode: zoom (scales to fit screen)
gsettings set org.gnome.desktop.background picture-options 'zoom'
```

---

## 🎯 User Experience

### After Installation:
1. ✅ Default wallpaper automatically set
2. ✅ All 7 wallpapers available in Settings
3. ✅ Easy to switch between wallpapers
4. ✅ Can add more wallpapers anytime

### Changing Wallpaper (GUI):
```
Settings → Appearance → Background → Add Picture
Navigate to: ~/.local/share/backgrounds/omakub/
Select any wallpaper
```

### Changing Wallpaper (CLI):
```bash
# Choose different wallpaper
WALLPAPER="$HOME/.local/share/backgrounds/omakub/pexels-felix-mittermeier-956981.jpg"
gsettings set org.gnome.desktop.background picture-uri "file://$WALLPAPER"
gsettings set org.gnome.desktop.background picture-uri-dark "file://$WALLPAPER"
```

---

## 🖼️ Wallpaper Details

### Your Default Wallpaper:
**Filename**: pexels-pok-rie-33563-2049422.jpg  
**Type**: Mountain landscape with dramatic sky  
**Style**: Nature/Landscape  
**Colors**: Blues, grays, natural tones  
**Mood**: Inspiring, peaceful, professional  
**Best For**: Professional desktop environment  

### Display Mode: Zoom
- Scales image to fill screen
- Maintains aspect ratio
- Centers the image
- No stretching or distortion

---

## 💡 Customization Options

### Add Your Own Wallpapers:

**Before Installation:**
```bash
# Add wallpapers to the fork
cd /Users/ben/Documents/bentobox/omakub/wallpaper/
cp ~/my-custom-wallpaper.jpg .
```

**After Installation:**
```bash
# Add wallpapers directly to user directory
cp ~/my-custom-wallpaper.jpg ~/.local/share/backgrounds/omakub/

# Set it as wallpaper
gsettings set org.gnome.desktop.background picture-uri "file://$HOME/.local/share/backgrounds/omakub/my-custom-wallpaper.jpg"
```

### Change Default Wallpaper:

Edit `install/desktop/set-wallpaper.sh` line 18:
```bash
# Change this to any wallpaper in the directory
DEFAULT_WALLPAPER="$WALLPAPER_DEST_DIR/pexels-felix-mittermeier-956981.jpg"
```

### Change Display Mode:

Options: `none`, `wallpaper`, `centered`, `scaled`, `stretched`, `zoom`, `spanned`

```bash
gsettings set org.gnome.desktop.background picture-options 'scaled'
```

---

## 🎨 Wallpaper Collection Theme

All wallpapers are:
- ✅ High resolution
- ✅ Professional/nature themed
- ✅ Non-distracting
- ✅ Free to use (from Pexels)
- ✅ Suitable for work environment

### Color Palettes:
- **Blues & Grays**: Mountain scenes, calm tones
- **Natural Colors**: Earth tones, greens, blues
- **Professional**: Not too bright or distracting
- **Modern**: Clean, crisp images

---

## 📊 Storage Impact

**Total Size**: ~10-15 MB for all 7 wallpapers  
**Location**: `~/.local/share/backgrounds/omakub/`  
**Impact**: Minimal - less than 20 MB total

---

## 🔄 Theme Integration

### Wallpaper vs Theme:
- **Theme**: Controls colors, icons, UI appearance
- **Wallpaper**: Your custom selection (overrides theme wallpaper)

The installation:
1. Loads Tokyo Night theme settings
2. Applies theme colors and UI
3. **Overrides** theme wallpaper with your custom choice

Result: You get Tokyo Night theme colors with your custom wallpaper!

---

## 🧪 Testing

After installation, verify:

```bash
# Check wallpapers copied
ls -la ~/.local/share/backgrounds/omakub/
# Should show 7 .jpg files

# Check current wallpaper setting
gsettings get org.gnome.desktop.background picture-uri
# Should show: 'file:///home/USERNAME/.local/share/backgrounds/omakub/pexels-pok-rie-33563-2049422.jpg'

# View wallpaper info
gsettings get org.gnome.desktop.background picture-options
# Should show: 'zoom'
```

---

## 📝 Complete Installation Flow

```
User runs Omakub installation
    ↓
Desktop installation phase starts
    ↓
set-gnome-theme.sh executes
    ↓
Loads Tokyo Night theme colors
    ↓
set-wallpaper.sh executes
    ↓
Copies 7 wallpapers to ~/.local/share/backgrounds/omakub/
    ↓
Sets pexels-pok-rie-33563-2049422.jpg as default
    ↓
System reboots
    ↓
User sees: Tokyo Night theme + Custom wallpaper ✨
```

---

## 🎉 Benefits

### For Users:
- ✅ Beautiful default wallpaper set automatically
- ✅ Multiple options to choose from
- ✅ Easy to change anytime
- ✅ Professional appearance out of the box

### For You (Fork Maintainer):
- ✅ Curated wallpaper collection
- ✅ Consistent branding
- ✅ Easy to update wallpapers
- ✅ Users can add their own

---

## 🔮 Future Enhancements

### Possible Additions:

1. **Wallpaper Selector During Installation**:
```bash
# Add to first-run-choices.sh
AVAILABLE_WALLPAPERS=("Mountain 1" "Mountain 2" "Nature 1" ...)
export OMAKUB_WALLPAPER=$(gum choose "${AVAILABLE_WALLPAPERS[@]}")
```

2. **Dynamic Wallpaper** (changes based on time):
```bash
# Set different wallpapers for day/night
gsettings set org.gnome.desktop.background picture-uri "file://day.jpg"
gsettings set org.gnome.desktop.background picture-uri-dark "file://night.jpg"
```

3. **Wallpaper Rotation Script**:
```bash
# Automatic wallpaper changer
crontab -e
# Add: 0 */4 * * * /usr/local/bin/rotate-wallpaper.sh
```

4. **Download Additional Wallpapers**:
```bash
# Add installer for wallpaper packs
source install/desktop/optional/wallpaper-pack-nature.sh
```

---

## 📄 Summary

### Files Summary:
- **Created**: 2 files (set-wallpaper.sh, wallpaper/README.md)
- **Modified**: 1 file (set-gnome-theme.sh)
- **Wallpapers**: 7 images included

### Default Behavior:
- ✅ Wallpapers automatically installed
- ✅ Default wallpaper automatically set
- ✅ Works with theme system
- ✅ User can easily change

### Storage:
- **Size**: ~15 MB
- **Location**: ~/.local/share/backgrounds/omakub/

---

**Your Omakub fork now has beautiful, professional wallpapers! 🎨✨**

