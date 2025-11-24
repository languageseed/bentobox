#!/bin/bash

# Display system information in the terminal
if ! command -v fastfetch &> /dev/null; then
    sudo add-apt-repository -y ppa:zhangsongcui3371/fastfetch
    sudo apt update -y
    sudo apt install -y fastfetch
else
    echo "✓ fastfetch already installed"
fi

# Only attempt to set configuration if fastfetch is not already set
if [ ! -f "$HOME/.config/fastfetch/config.jsonc" ]; then
  # Use Omakub fastfetch config
  mkdir -p ~/.config/fastfetch
  cp $OMAKUB_PATH/configs/fastfetch.jsonc ~/.config/fastfetch/config.jsonc
fi
