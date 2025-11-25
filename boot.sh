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
echo "=> Bentobox - Professional development environment"
echo "=> Ubuntu 24.04+ or Debian 13+ (fresh installations recommended)"
echo "=> Fork of Omakub by languageseed"
echo -e "\nBegin installation (or abort with ctrl+c)..."

# Detect distribution
if [ -f /etc/os-release ]; then
    . /etc/os-release
    DISTRO_ID="$ID"
else
    DISTRO_ID="unknown"
fi

# Debian-specific: Install prerequisites first
if [[ "$DISTRO_ID" == "debian" ]] || [[ "$DISTRO_ID" == "raspbian" ]]; then
    echo "📦 Installing Debian prerequisites..."
    sudo apt-get update >/dev/null
    sudo apt-get install -y git python3-pip python3-yaml build-essential >/dev/null
    echo "✓ Prerequisites installed"
else
    sudo apt-get update >/dev/null
    sudo apt-get install -y git >/dev/null
fi

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
