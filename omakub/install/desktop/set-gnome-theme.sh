#!/bin/bash

# Load theme settings but skip wallpaper (we use custom wallpaper)
source ~/.local/share/omakub/themes/tokyo-night/gnome.sh
source ~/.local/share/omakub/themes/tokyo-night/tophat.sh

# Note: Wallpaper and GDM background are set by separate scripts:
# - set-wallpaper.sh (runs after this script alphabetically)
# - z-set-gdm-background.sh (runs after wallpaper setup)
# - z-set-gdm-greeter-background.sh (runs after wallpaper setup)
