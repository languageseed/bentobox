#!/bin/bash

# Check if VS Code should be skipped (already installed)
if [ "$SKIP_VSCODE" = "true" ]; then
    echo "✓ VS Code already installed, skipping..."
    exit 0
fi

if [ ! -f /etc/apt/keyrings/packages.microsoft.gpg ] || [ ! -f /usr/share/keyrings/microsoft.gpg ]; then
  [ -f /etc/apt/keyrings/packages.microsoft.gpg ] && sudo rm /etc/apt/keyrings/packages.microsoft.gpg
  cd /tmp
  wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor >packages.microsoft.gpg
  sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
  echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list >/dev/null
  rm -f packages.microsoft.gpg
  cd -
fi

sudo apt update
sudo apt install -y code

mkdir -p ~/.config/Code/User
cp $OMAKUB_PATH/configs/vscode.json ~/.config/Code/User/settings.json

# Install default supported themes (may crash over SSH, so wrap carefully)
(code --install-extension enkia.tokyo-night 2>/dev/null) || echo "⚠️  VS Code extension installation skipped (requires graphical session)"