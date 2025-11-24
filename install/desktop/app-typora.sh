#!/bin/bash

# Check if already installed
if command -v typora &> /dev/null; then
    echo "✓ Typora already installed, skipping..."
    exit 0
fi

# Typora is a markdown editor and reader. See https://typora.io/
if [ ! -f /etc/apt/sources.list.d/typora.list ]; then
  [ -f /etc/apt/keyrings/typora.gpg ] && sudo rm /etc/apt/keyrings/typora.gpg
  sudo mkdir -p /etc/apt/keyrings
  curl -fsSL https://downloads.typora.io/typora.gpg | sudo tee /etc/apt/keyrings/typora.gpg > /dev/null
  echo "deb [signed-by=/etc/apt/keyrings/typora.gpg] https://downloads.typora.io/linux ./" | sudo tee /etc/apt/sources.list.d/typora.list
  sudo apt update
fi

sudo apt install typora -y

# Add iA Typora theme
mkdir -p ~/.config/Typora/themes
cp $OMAKUB_PATH/configs/typora/ia_typora.css ~/.config/Typora/themes/
cp $OMAKUB_PATH/configs/typora/ia_typora_night.css ~/.config/Typora/themes/
