#!/bin/bash

# Run desktop installers
for installer in ~/.local/share/omakub/install/desktop/*.sh; do source $installer; done

# Logout to pickup changes (only prompt in interactive mode)
if [ -t 0 ] && [ -t 1 ]; then
  gum confirm "Ready to reboot for all settings to take effect?" && sudo reboot || true
else
  echo ""
  echo "✅ Installation complete!"
  echo "⚠️  Please reboot for all settings to take effect: sudo reboot"
fi
