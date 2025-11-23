#!/bin/bash

# Alacritty is a GPU-powered and highly extensible terminal. See https://alacritty.org/
sudo apt install -y alacritty
mkdir -p ~/.config/alacritty
cp $OMAKUB_PATH/configs/alacritty.toml ~/.config/alacritty/alacritty.toml
cp $OMAKUB_PATH/configs/alacritty/shared.toml ~/.config/alacritty/shared.toml
cp $OMAKUB_PATH/configs/alacritty/pane.toml ~/.config/alacritty/pane.toml
cp $OMAKUB_PATH/configs/alacritty/btop.toml ~/.config/alacritty/btop.toml
cp $OMAKUB_PATH/themes/tokyo-night/alacritty.toml ~/.config/alacritty/theme.toml
cp $OMAKUB_PATH/configs/alacritty/fonts/CaskaydiaMono.toml ~/.config/alacritty/font.toml
cp $OMAKUB_PATH/configs/alacritty/font-size.toml ~/.config/alacritty/font-size.toml

# Migrate config format if needed
alacritty migrate 2>/dev/null || true
alacritty migrate -c ~/.config/alacritty/pane.toml 2>/dev/null || true
alacritty migrate -c ~/.config/alacritty/btop.toml 2>/dev/null || true

source $OMAKUB_PATH/install/desktop/set-alacritty-default.sh
