#!/bin/bash

# Check if running in a full graphical session
HAS_DISPLAY=false
if [ -n "$DISPLAY" ] || [ -n "$WAYLAND_DISPLAY" ]; then
    HAS_DISPLAY=true
fi

# Run desktop installers (with error tolerance)
# Disable strict error checking for desktop installations to prevent one failure from stopping everything
set +e
for installer in $OMAKUB_PATH/install/desktop/*.sh; do
    # Skip desktop.sh to avoid sourcing itself
    [[ "$installer" == */desktop.sh ]] && continue
    
    echo "Running: $(basename $installer)"
    source $installer || echo "⚠️  $(basename $installer) had issues but continuing..."
done
set -e  # Re-enable strict error checking

# If we're not in a display session, create a finish script
if [ "$HAS_DISPLAY" = "false" ]; then
    cat > ~/bentobox-finish-setup.sh << 'FINISH_SCRIPT'
#!/bin/bash
# Bentobox Desktop Finalization
# Run this from the GNOME desktop session to complete customization

echo "🎨 Completing Bentobox desktop setup..."
echo ""

# Check if we're in a GNOME session
if [ -z "$DISPLAY" ] && [ -z "$WAYLAND_DISPLAY" ]; then
    echo "❌ ERROR: This must be run from within a GNOME desktop session"
    echo "   Please open a terminal on the desktop (Ctrl+Alt+T) and run:"
    echo "   ./bentobox-finish-setup.sh"
    exit 1
fi

cd ~/.local/share/omakub || exit 1

# Apply GNOME theme and settings
echo "🎨 Applying GNOME theme..."
bash ./install/desktop/set-gnome-theme.sh

# Apply GNOME settings
echo "⚙️  Configuring GNOME settings..."
bash ./install/desktop/set-gnome-settings.sh

# Set up hotkeys
echo "⌨️  Setting up hotkeys..."
bash ./install/desktop/set-gnome-hotkeys.sh

# Install GNOME extensions (requires popups)
echo ""
echo "🧩 Installing GNOME extensions..."
echo "   You will see browser popups to approve each extension."
read -p "Press Enter when ready to continue..." 
bash ./install/desktop/set-gnome-extensions.sh

echo ""
echo "✅ Desktop setup complete!"
echo ""
echo "Please press Alt+F2, type 'r', and press Enter to restart GNOME Shell"
echo "Or log out and log back in for all changes to take effect."
FINISH_SCRIPT
    
    chmod +x ~/bentobox-finish-setup.sh
    
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "⚠️  Desktop customization requires graphical session"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "To complete the setup:"
    echo "  1. Log into the GNOME desktop"
    echo "  2. Open terminal (Ctrl+Alt+T)"
    echo "  3. Run: ./bentobox-finish-setup.sh"
    echo ""
fi

# Logout to pickup changes
echo ""
echo "✅ Installation complete!"

# Handle reboot based on mode
if [ "$BENTOBOX_MODE" = "unattended" ] || [ "$BENTOBOX_AI_MODE" = "true" ]; then
    if [ "$BENTOBOX_AUTO_REBOOT" = "true" ]; then
        echo "🔄 Auto-rebooting in 5 seconds..."
        sleep 5
        sudo reboot
    else
        echo "⚠️  Reboot required: sudo reboot"
        echo "   (Set 'auto_reboot: true' in config to reboot automatically)"
    fi
else
    # Interactive mode - ask user
    if [ "$HAS_DISPLAY" = "true" ]; then
        gum confirm "Ready to reboot for all settings to take effect?" && sudo reboot || echo "⚠️  Please reboot manually: sudo reboot"
    else
        echo "⚠️  Please reboot and run ~/bentobox-finish-setup.sh from the desktop"
    fi
fi

