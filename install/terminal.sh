#!/bin/bash

# Needed for all installers - check if already installed
if ! command -v curl &> /dev/null || ! command -v git &> /dev/null || ! command -v unzip &> /dev/null; then
    echo "Installing base requirements (curl, git, unzip)..."
    sudo apt update -y
    sudo apt install -y curl git unzip
else
    echo "✓ Base requirements already installed"
fi

# Only run apt upgrade if explicitly requested or in fresh install
if [ "$BENTOBOX_AUTO_UPGRADE" = "true" ] || [ ! -f ~/.local/share/omakub/.installed ]; then
    echo "Running apt upgrade..."
    sudo apt upgrade -y
else
    echo "✓ Skipping apt upgrade (set BENTOBOX_AUTO_UPGRADE=true to force)"
fi

# Run terminal installers (exclude terminal.sh itself to avoid infinite loop)
for installer in $OMAKUB_PATH/install/terminal/*.sh; do
    # Skip terminal.sh to avoid sourcing itself
    [[ "$installer" == */terminal.sh ]] && continue
    source $installer
done

# Mark installation as complete
mkdir -p ~/.local/share/omakub
touch ~/.local/share/omakub/.installed
