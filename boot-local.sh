#!/bin/bash

set -e

ascii_art='
________                     __        __
\______   \  ____   __  ____/  |____  |  |__   _______  ___
 |    |  _/_/ __ \ /  \|  \   __\  _ \ |  |  \ /  _ \  \/  /
 |    |   \\  ___/ |   |  ||  | |  |_| >   Y  (  |_| )>    <
 |________/\___  >|___|  ||__|  \____/|___|  / \____/__/\_ \
               \/      \/                   \/             \/
'

echo -e "$ascii_art"
echo "=> Bentobox v2.0 (Build 1f07848 - LOCAL) - Nov 23, 2025"
echo "=> Fresh Ubuntu 24.04+ installations only"
echo "=> Custom fork by languageseed - Professional development environment"
echo -e "\nBegin installation (or abort with ctrl+c)..."

# Install git if not present
sudo apt-get update >/dev/null
sudo apt-get install -y git >/dev/null

echo "Using local Bentobox files..."
# Copy local files to ~/.local/share/omakub
rm -rf ~/.local/share/omakub
mkdir -p ~/.local/share
cp -r ~/bentobox-install ~/.local/share/omakub

echo "Installation starting..."
source ~/.local/share/omakub/install.sh



