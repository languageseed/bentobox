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
echo "=> Bentobox v2.0 (Build 44c3ce1) - Nov 23, 2025"
echo "=> Fresh Ubuntu 24.04+ installations only"
echo "=> Custom fork by languageseed - Professional development environment"
echo -e "\nBegin installation (or abort with ctrl+c)..."

sudo apt-get update >/dev/null
sudo apt-get install -y git >/dev/null

echo "Cloning Bentobox..."
rm -rf ~/.local/share/omakub
git clone https://github.com/languageseed/bentobox.git ~/.local/share/omakub
cd ~/.local/share/omakub
git checkout -f HEAD
cd ~
if [[ $OMAKUB_REF != "master" ]]; then
	cd ~/.local/share/omakub
	git fetch origin "${OMAKUB_REF:-stable}" && git checkout "${OMAKUB_REF:-stable}"
	cd -
fi

echo "Installation starting..."
source ~/.local/share/omakub/install.sh
