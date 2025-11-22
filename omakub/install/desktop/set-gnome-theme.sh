#!/bin/bash

# Load theme settings but skip wallpaper (we use custom wallpaper)
source ~/.local/share/omakub/themes/tokyo-night/gnome.sh
source ~/.local/share/omakub/themes/tokyo-night/tophat.sh

# Override with custom wallpaper
source ~/.local/share/omakub/install/desktop/set-wallpaper.sh

# Set GDM (login screen) background to match
source ~/.local/share/omakub/install/desktop/set-gdm-background.sh
