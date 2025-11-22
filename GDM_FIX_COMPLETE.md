# GDM Login Screen Background Fix - COMPLETE ✅

## Issue Resolved
The GDM (GNOME Display Manager) login screen background now matches the custom Bentobox wallpaper on Ubuntu 24.04.

## Date
November 22, 2024

## Solution
Ubuntu 24.04 uses compiled gresource files for GDM themes, which makes simple CSS or dconf modifications ineffective. The working solution involves:

1. **Extract**: Extract `gdm.css` from the compiled gresource file
2. **Modify**: Add custom CSS targeting the GDM login screen
3. **Recompile**: Recompile into a new gresource file
4. **Install**: Install the custom gresource as the GDM theme

## Implementation
The fix has been implemented in:

**File**: `omakub/install/desktop/set-gdm-background.sh`

This script:
- Copies the Bentobox wallpaper to `/usr/share/backgrounds/bentobox/`
- Extracts `gdm.css` from the system gresource
- Appends custom CSS for the GDM background
- Recompiles the gresource with the modified CSS
- Installs it as the system GDM theme

## CSS Used
```css
/* Bentobox GDM Background */
#lockDialogGroup {
  background: url(file:///usr/share/backgrounds/bentobox/login-background.jpg);
  background-size: cover !important;
  background-position: center !important;
  background-repeat: no-repeat !important;
}

stage {
  background: url(file:///usr/share/backgrounds/bentobox/login-background.jpg);
  background-size: cover;
}
```

## Testing
- ✅ Tested on Ubuntu 24.04 desktop
- ✅ User session wallpaper: Working
- ✅ Lock screen wallpaper: Working
- ✅ GDM login screen: **WORKING** (Previously failed)

## Integration
The script is automatically called during Bentobox installation as part of:
`omakub/install/desktop/set-gnome-theme.sh`

## Previous Attempts (Failed)
1. ❌ dconf settings for GDM user
2. ❌ Direct CSS modification (ubuntu.css)
3. ❌ Direct CSS modification (Yaru theme)
4. ❌ Replacing warty-final-ubuntu.png
5. ❌ gdm-background script (outdated)

## Why This Works
Ubuntu 24.04's GDM loads themes from compiled gresource files. By extracting, modifying, and recompiling the gresource with our custom CSS, we're working with the system the way it was designed, rather than trying to override it through other methods.

## Commands to Verify
```bash
# Check if custom gresource exists
ls -l /usr/share/gnome-shell/gdm-theme.gresource

# Check wallpaper is in place
ls -l /usr/share/backgrounds/bentobox/login-background.jpg

# View installed alternatives
update-alternatives --query gdm-theme.gresource

# Restart GDM to apply (saves all work first!)
sudo systemctl restart gdm3
```

## Documentation Updates
- ✅ Removed "GDM Login Screen Background" from Known Issues in README
- ✅ Updated `set-gdm-background.sh` with working solution
- ✅ Committed to repository
- ✅ Pushed to GitHub: https://github.com/languageseed/bentobox

## Result
All three wallpaper contexts now work correctly:
1. **Desktop session**: Custom Bentobox wallpaper ✅
2. **Lock screen**: Custom Bentobox wallpaper ✅
3. **GDM login screen**: Custom Bentobox wallpaper ✅

The Bentobox fork is now feature-complete with full visual customization!

