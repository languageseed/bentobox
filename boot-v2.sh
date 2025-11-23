#!/bin/bash

ascii_art='
________                     __        __
\______   \  ____   __  ____/  |____  |  |__   _______  ___
 |    |  _/_/ __ \ /  \|  \   __\  _ \ |  |  \ /  _ \  \/  /
 |    |   \\  ___/ |   |  ||  | |  |_| >   Y  (  |_| )>    <
 |________/\___  >|___|  ||__|  \____/|___|  / \____/__/\_ \
               \/      \/                   \/             \/
'

echo -e "$ascii_art"
echo "=> Bentobox v2.0 (Build 4d569d8) - Nov 23, 2025"
echo "=> Fresh Ubuntu 24.04+ installations only"
echo "=> Custom fork by languageseed - Professional development environment"
echo -e "\nBegin installation (or abort with ctrl+c)..."

sudo apt-get update >/dev/null
sudo apt-get install -y git >/dev/null

echo "Cloning Bentobox..."
rm -rf ~/.local/share/omakub
git clone --depth 1 https://github.com/languageseed/bentobox.git ~/.local/share/omakub

if [ ! -d ~/.local/share/omakub ]; then
	echo "❌ Failed to clone repository!"
	exit 1
fi

cd ~/.local/share/omakub

# Verify critical directories exist
CRITICAL_PATHS=(
	"install.sh"
	"configs"
	"themes"
	"wallpaper"
	"applications"
)

MISSING=0
for path in "${CRITICAL_PATHS[@]}"; do
	if [ ! -e "$path" ]; then
		echo "❌ Missing: $path"
		MISSING=1
	fi
done

if [ $MISSING -eq 1 ]; then
	echo "❌ Critical files missing! Clone incomplete."
	echo "This may be a GitHub CDN caching issue."
	echo "Please try again in a few minutes or clone manually:"
	echo "  git clone https://github.com/languageseed/bentobox.git ~/.local/share/omakub"
	exit 1
fi

cd ~

if [[ $OMAKUB_REF != "master" ]]; then
	cd ~/.local/share/omakub
	git fetch origin "${OMAKUB_REF:-stable}" && git checkout "${OMAKUB_REF:-stable}"
	cd -
fi

echo "✅ Repository cloned successfully"
echo "Installation starting..."
source ~/.local/share/omakub/install.sh
