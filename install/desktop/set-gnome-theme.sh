#!/bin/bash

# Load theme settings but skip wallpaper (we use custom wallpaper)
source $OMAKUB_PATH/themes/tokyo-night/gnome.sh
source $OMAKUB_PATH/themes/tokyo-night/tophat.sh

# Override with custom wallpaper
source $OMAKUB_PATH/install/desktop/set-wallpaper.sh

# Set GDM (login screen) background to match
source $OMAKUB_PATH/install/desktop/set-gdm-background.sh
