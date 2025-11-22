# Custom Wallpapers

This directory contains curated wallpapers for your Omakub installation.

## Available Wallpapers

1. **pexels-pok-rie-33563-2049422.jpg** ⭐ (Default)
   - Mountain landscape with dramatic sky
   - Resolution: High quality
   - Style: Nature/Landscape

2. **pexels-eberhardgross-1062249.jpg**
   - Nature scene
   - Style: Landscape

3. **pexels-eberhardgross-443446.jpg**
   - Nature scene
   - Style: Landscape

4. **pexels-eberhardgross-640781.jpg**
   - Nature scene
   - Style: Landscape

5. **pexels-felix-mittermeier-956981.jpg**
   - Nature scene
   - Style: Landscape

6. **pexels-philippedonn-1169754.jpg**
   - Nature scene
   - Style: Landscape

7. **pexels-pok-rie-33563-982263.jpg**
   - Mountain landscape
   - Style: Nature/Landscape

## Installation

During installation, all wallpapers are automatically copied to:
`~/.local/share/backgrounds/omakub/`

The default wallpaper (pexels-pok-rie-33563-2049422.jpg) is automatically set.

## Changing Wallpaper

### Via GUI:
1. Open **Settings**
2. Go to **Appearance**
3. Click **Background**
4. Click **Add Picture**
5. Navigate to `~/.local/share/backgrounds/omakub/`
6. Select your preferred wallpaper

### Via Command Line:
```bash
# Set a different wallpaper
WALLPAPER="$HOME/.local/share/backgrounds/omakub/pexels-felix-mittermeier-956981.jpg"
gsettings set org.gnome.desktop.background picture-uri "file://$WALLPAPER"
gsettings set org.gnome.desktop.background picture-uri-dark "file://$WALLPAPER"
```

## Adding Your Own Wallpapers

1. Add your .jpg files to this `wallpaper/` directory
2. They will be automatically copied during installation
3. Access them from Settings > Appearance > Background

## Wallpaper Options

The wallpapers are set to **zoom** mode by default, which scales the image to fit the screen while maintaining aspect ratio.

To change this:
```bash
# Options: 'none', 'wallpaper', 'centered', 'scaled', 'stretched', 'zoom', 'spanned'
gsettings set org.gnome.desktop.background picture-options 'zoom'
```

## Credits & License

All wallpapers are from Pexels (https://www.pexels.com) and are licensed under the **Pexels License**.

### Pexels License

License URL: https://www.pexels.com/license/

According to the Pexels License, you can:
- ✅ Use for free
- ✅ Use for personal and commercial purposes
- ✅ Modify, copy, and distribute
- ✅ Use without attribution (though appreciated)

You cannot:
- ❌ Sell copies of the photos without modification
- ❌ Use identifiable people or brands for commercial purposes without permission
- ❌ Compile photos to replicate similar services

### Photographer Credits

All photos are courtesy of talented Pexels photographers:
- **Pok Rie** - Mountain landscapes (2 photos)
- **Eberhard Grossgasteiger** - Nature scenes (3 photos)
- **Felix Mittermeier** - Landscape photography (1 photo)
- **Philippe Donn** - Nature photography (1 photo)

### Thank You

A huge thank you to the Pexels community and all photographers who make their work freely available for everyone to use.

