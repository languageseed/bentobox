#!/bin/bash
# BENTOBOX_EXTENSION: v1
# NAME: [App Display Name] - [Short Description]
# DESCRIPTION: [Detailed description of what this application does]
# CATEGORY: [Communication|Development|Graphics|Productivity|Media|Utilities|Gaming|Security|Education|Internet]
# ICON: [icon-name]
# HOMEPAGE: https://[app-website].com
# CHECK_COMMAND: [command-to-check-if-installed]
# REQUIRES: [comma-separated-dependencies]
# CONFLICTS: [comma-separated-conflicting-packages]
# AUTHOR: [Your Name or Organization]
# VERSION: 1.0

# =============================================================================
# INSTALLATION SCRIPT
# =============================================================================

# Check if already installed (REQUIRED)
if command -v [app-command] &> /dev/null; then
    echo "✓ [App Name] already installed, skipping..."
    exit 0
fi

# Display installation message
echo "📦 Installing [App Name]..."

# =============================================================================
# INSTALLATION COMMANDS
# Choose the appropriate method for your application:
# =============================================================================

# METHOD 1: APT (Ubuntu package manager)
# sudo apt update
# sudo apt install -y [package-name]

# METHOD 2: Snap
# sudo snap install [package-name]
# For classic snaps: sudo snap install [package-name] --classic

# METHOD 3: Flatpak
# flatpak install -y flathub [app-id]
# Example: flatpak install -y flathub com.slack.Slack

# METHOD 4: Download .deb package
# TEMP_DEB=$(mktemp)
# wget -O $TEMP_DEB https://[url-to-deb-file]
# sudo dpkg -i $TEMP_DEB
# sudo apt-get install -f -y  # Fix dependencies
# rm $TEMP_DEB

# METHOD 5: Add PPA and install
# sudo add-apt-repository -y ppa:[ppa-name]
# sudo apt update
# sudo apt install -y [package-name]

# METHOD 6: AppImage
# mkdir -p ~/.local/bin
# wget -O ~/.local/bin/[app-name] https://[url-to-appimage]
# chmod +x ~/.local/bin/[app-name]

# METHOD 7: Manual script installation
# wget -O /tmp/install.sh https://[url-to-install-script]
# bash /tmp/install.sh
# rm /tmp/install.sh

# =============================================================================
# ADD YOUR INSTALLATION COMMAND HERE:
# =============================================================================

# [Your installation command here]

# =============================================================================
# VERIFICATION (REQUIRED)
# =============================================================================

# Verify installation was successful
if command -v [app-command] &> /dev/null; then
    echo "✅ [App Name] installed successfully"
    # Optional: Display version or additional info
    # [app-command] --version
    exit 0
else
    echo "❌ [App Name] installation failed"
    exit 1
fi

# =============================================================================
# NOTES:
# - Replace all [bracketed] placeholders with actual values
# - Remove unused installation methods
# - Test script with: bash -n script.sh (syntax check)
# - Test installation: bash script.sh
# - Test idempotency: bash script.sh (run again, should skip)
# - Make executable: chmod +x script.sh
# =============================================================================

