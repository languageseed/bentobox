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
echo "=> Bentobox v2.0 (Build 1766ae5) - Nov 23, 2025"
echo "=> Fresh Ubuntu 24.04+ installations only"
echo "=> Custom fork by languageseed - Professional development environment"
echo -e "\nBegin installation (or abort with ctrl+c)..."

sudo apt-get update >/dev/null
sudo apt-get install -y git >/dev/null

# Set installation path
export OMAKUB_PATH="$HOME/.local/share/omakub"

echo "Cloning Bentobox..."
rm -rf "$OMAKUB_PATH"
git clone --depth 1 https://github.com/languageseed/bentobox.git "$OMAKUB_PATH"

if [ ! -d "$OMAKUB_PATH" ]; then
	echo "❌ Failed to clone repository!"
	exit 1
fi

cd "$OMAKUB_PATH"

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
	echo "  git clone https://github.com/languageseed/bentobox.git $OMAKUB_PATH"
	exit 1
fi

cd ~

if [[ $OMAKUB_REF != "master" ]]; then
	cd "$OMAKUB_PATH"
	git fetch origin "${OMAKUB_REF:-stable}" && git checkout "${OMAKUB_REF:-stable}"
	cd -
fi

echo "✅ Repository cloned successfully"
echo "Installation starting..."
source "$OMAKUB_PATH/install.sh"
