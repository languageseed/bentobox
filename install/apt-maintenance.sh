#!/bin/bash
# APT System Maintenance
# Handles apt update/upgrade before bentobox installation

echo "🔧 APT System Maintenance"
echo ""

# Check if we need to run apt update
if [ "$BENTOBOX_NEEDS_APT_UPDATE" = "true" ] || [ "$1" = "force" ]; then
    echo "📥 Updating package lists..."
    sudo apt update
    echo "✅ Package lists updated"
    echo ""
fi

# Check if we should run apt upgrade
if [ "$BENTOBOX_NEEDS_APT_UPGRADE" = "true" ] || [ "$1" = "force-upgrade" ]; then
    PENDING=$(apt list --upgradable 2>/dev/null | grep -c upgradable || echo "0")
    
    if [ "$PENDING" -gt 0 ]; then
        echo "📦 $PENDING packages have updates available"
        
        # Interactive mode - ask user
        if [ "$BENTOBOX_MODE" = "interactive" ]; then
            if command -v gum &> /dev/null; then
                if gum confirm "Run apt upgrade now? (Recommended for fresh installs)"; then
                    echo "⬆️  Upgrading packages..."
                    sudo apt upgrade -y
                    echo "✅ Packages upgraded"
                else
                    echo "⏭️  Skipping apt upgrade"
                fi
            else
                read -p "Run apt upgrade now? (y/N) " -n 1 -r
                echo
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                    echo "⬆️  Upgrading packages..."
                    sudo apt upgrade -y
                    echo "✅ Packages upgraded"
                else
                    echo "⏭️  Skipping apt upgrade"
                fi
            fi
        # Unattended mode - check config
        elif [ "$BENTOBOX_MODE" = "unattended" ] || [ "$BENTOBOX_AI_MODE" = "true" ]; then
            # Check config for auto_upgrade setting
            if [ "$BENTOBOX_AUTO_UPGRADE" = "true" ]; then
                echo "⬆️  Auto-upgrading packages (unattended mode)..."
                sudo apt upgrade -y
                echo "✅ Packages upgraded"
            else
                echo "⏭️  Skipping apt upgrade (set auto_upgrade: true in config to enable)"
            fi
        fi
    else
        echo "✅ System packages already up to date"
    fi
    echo ""
fi

# Clean up apt cache if needed
CACHE_SIZE=$(du -sh /var/cache/apt/archives 2>/dev/null | cut -f1 || echo "0M")
echo "💾 APT cache size: $CACHE_SIZE"

# If cache is large (>500MB), offer to clean
CACHE_MB=$(du -sm /var/cache/apt/archives 2>/dev/null | cut -f1 || echo "0")
if [ "$CACHE_MB" -gt 500 ]; then
    echo "   (Large cache - consider running: sudo apt autoclean)"
fi

echo ""

