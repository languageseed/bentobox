#!/bin/bash

# Run desktop installers
for installer in $OMAKUB_PATH/install/desktop/*.sh; do source $installer; done

# Logout to pickup changes
echo ""
echo "✅ Installation complete!"
gum confirm "Ready to reboot for all settings to take effect?" && sudo reboot || echo "⚠️  Please reboot manually: sudo reboot"

