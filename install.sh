#!/bin/bash

# Set OMAKUB_PATH if not already set
export OMAKUB_PATH="${OMAKUB_PATH:-$HOME/.local/share/omakub}"

# Exit immediately if a command exits with a non-zero status
set -e

# Give people a chance to retry running the installation
trap 'echo "Omakub installation failed! You can retry by running: source $OMAKUB_PATH/install.sh"' ERR

# Check the distribution name and version and abort if incompatible
source "$OMAKUB_PATH/install/check-version.sh"

# Ask for app choices
echo "Get ready to make a few choices..."
source "$OMAKUB_PATH/install/terminal/required/app-gum.sh" >/dev/null
source "$OMAKUB_PATH/install/first-run-choices.sh"
source "$OMAKUB_PATH/install/identification.sh"

# Desktop software and tweaks will only be installed if we're running Gnome
if [[ "$XDG_CURRENT_DESKTOP" == *"GNOME"* ]]; then
  # Ensure computer doesn't go to sleep or lock while installing
  gsettings set org.gnome.desktop.screensaver lock-enabled false
  gsettings set org.gnome.desktop.session idle-delay 0

  echo "Installing terminal and desktop tools..."

  # Install terminal tools
  source "$OMAKUB_PATH/install/terminal.sh"

  # Install desktop tools and tweaks
  source "$OMAKUB_PATH/install/desktop.sh"

  # Revert to normal idle and lock settings
  gsettings set org.gnome.desktop.screensaver lock-enabled true
  gsettings set org.gnome.desktop.session idle-delay 300
else
  echo "Only installing terminal tools..."
  source "$OMAKUB_PATH/install/terminal.sh"
fi
