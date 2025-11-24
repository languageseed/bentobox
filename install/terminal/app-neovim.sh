#!/bin/bash

# Check if Neovim should be skipped (already installed)
if [ "$SKIP_NEOVIM" = "true" ]; then
    echo "✓ Neovim already installed, skipping..."
    exit 0
fi

cd /tmp
wget -O nvim.tar.gz "https://github.com/neovim/neovim/releases/download/stable/nvim-linux-x86_64.tar.gz"
tar -xf nvim.tar.gz
sudo install nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim
sudo cp -R nvim-linux-x86_64/lib /usr/local/
sudo cp -R nvim-linux-x86_64/share /usr/local/
rm -rf nvim-linux-x86_64 nvim.tar.gz
cd -

# Install luarocks and tree-sitter-cli to resolve lazyvim :checkhealth warnings
sudo apt install -y luarocks tree-sitter-cli

# Only attempt to set configuration if Neovim has never been run
if [ ! -d "$HOME/.config/nvim" ]; then
  # Use LazyVim
  git clone https://github.com/LazyVim/starter ~/.config/nvim
  # Remove the .git folder, so you can add it to your own repo later
  rm -rf ~/.config/nvim/.git

  # Make everything match the terminal transparency
  mkdir -p ~/.config/nvim/plugin/after
  cp $OMAKUB_PATH/configs/neovim/transparency.lua ~/.config/nvim/plugin/after/ 2>/dev/null || echo "⚠️  Skipping neovim transparency config"

  # Default to Tokyo Night theme
  cp $OMAKUB_PATH/themes/tokyo-night/neovim.lua ~/.config/nvim/lua/plugins/theme.lua 2>/dev/null || echo "⚠️  Skipping neovim theme"

  # Turn off animated scrolling
  cp $OMAKUB_PATH/configs/neovim/snacks-animated-scrolling-off.lua ~/.config/nvim/lua/plugins/ 2>/dev/null || echo "⚠️  Skipping neovim scrolling config"

  # Turn off relative line numbers
  echo "vim.opt.relativenumber = false" >>~/.config/nvim/lua/config/options.lua

  # Ensure editor.neo-tree is used by default
  cp $OMAKUB_PATH/configs/neovim/lazyvim.json ~/.config/nvim/ 2>/dev/null || echo "⚠️  Skipping neovim lazyvim config"
fi

# Replace desktop launcher with one running inside Alacritty
if [[ -d ~/.local/share/applications ]]; then
  sudo rm -rf /usr/share/applications/nvim.desktop
  sudo rm -rf /usr/local/share/applications/nvim.desktop
  source $OMAKUB_PATH/applications/Neovim.sh
fi
