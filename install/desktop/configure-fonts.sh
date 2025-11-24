#!/bin/bash
# Configure fonts for GNOME terminal and system

# Set monospace font for GNOME Terminal and system
# CaskaydiaMono Nerd Font with size 11 (good balance)
gsettings set org.gnome.desktop.interface monospace-font-name 'CaskaydiaMono Nerd Font Mono 11'

# Set font for GNOME Terminal profiles
PROFILE=$(gsettings get org.gnome.Terminal.ProfilesList default | tr -d "'")
if [ -n "$PROFILE" ]; then
    gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$PROFILE/ use-system-font false
    gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$PROFILE/ font 'CaskaydiaMono Nerd Font Mono 11'
    
    # Disable bold text if it's causing spacing issues
    gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$PROFILE/ allow-bold true
    
    # Set good character spacing
    gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$PROFILE/ cell-height-scale 1.0
    gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$PROFILE/ cell-width-scale 1.0
fi

# Also set font for desktop/UI (optional, but good for consistency)
gsettings set org.gnome.desktop.interface font-name 'Ubuntu 11'
gsettings set org.gnome.desktop.interface document-font-name 'Ubuntu 11'

echo "✅ Fonts configured:"
echo "   Monospace: CaskaydiaMono Nerd Font Mono 11"
echo "   Terminal: CaskaydiaMono Nerd Font Mono 11"
echo ""
echo "Please restart GNOME Terminal (close and reopen) to see changes"

