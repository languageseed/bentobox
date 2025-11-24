#!/bin/bash
# Bentobox Installation - Modern orchestrator
# This script delegates to a Python orchestrator for proper error handling and state management

# Set OMAKUB_PATH if not already set
export OMAKUB_PATH="${OMAKUB_PATH:-$HOME/.local/share/omakub}"

# Check Python is available
if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 is required but not installed"
    echo "   Installing Python 3..."
    sudo apt update
    sudo apt install -y python3 python3-pip
fi

# Install PyYAML if needed
if ! python3 -c "import yaml" 2>/dev/null; then
    echo "📦 Installing Python dependencies..."
    pip3 install --user pyyaml
fi

# Check the distribution name and version and abort if incompatible
source "$OMAKUB_PATH/install/check-version.sh"

# Run the Python orchestrator
python3 "$OMAKUB_PATH/install/orchestrator.py" "$@"

# Check the distribution name and version and abort if incompatible
source "$OMAKUB_PATH/install/check-version.sh"

# Check terminal compatibility (important for SSH and TUI)
source "$OMAKUB_PATH/install/terminal-check.sh"

# Load configuration (interactive or unattended mode)
source "$OMAKUB_PATH/install/config-loader.sh"

# Interactive component selection (BEFORE pre-flight)
# This allows users to choose what to install before we scan the system
if [ "$BENTOBOX_MODE" = "interactive" ]; then
    # Install gum first for better TUI experience
    source "$OMAKUB_PATH/install/terminal/required/app-gum.sh" >/dev/null 2>&1 || true
    
    # Show pre-installation menu
    source "$OMAKUB_PATH/install/pre-installation-menu.sh"
    
    # Get user identification
    source "$OMAKUB_PATH/install/identification.sh"
fi

# Run pre-flight check (unless explicitly skipped)
if [ "$BENTOBOX_SKIP_PREFLIGHT" != "true" ]; then
    set +e  # Temporarily disable exit on error for preflight
    source "$OMAKUB_PATH/install/preflight-check.sh"
    PREFLIGHT_EXIT=$?
    set -e  # Re-enable exit on error
    
    # If preflight had warnings, decide whether to continue
    if [ $PREFLIGHT_EXIT -eq 2 ]; then
        # Warnings found
        if [ "$BENTOBOX_MODE" = "interactive" ]; then
            # Interactive mode - ask user
            echo "⚠️  Warnings detected. Continue anyway?"
            if command -v gum &> /dev/null && [ "$BENTOBOX_SIMPLE_PROMPTS" != "true" ]; then
                gum confirm "Continue with installation?" || exit 1
            else
                read -p "Continue? (y/N) " -n 1 -r
                echo
                [[ ! $REPLY =~ ^[Yy]$ ]] && exit 1
            fi
        elif [ "$BENTOBOX_MODE" = "unattended" ]; then
            # Unattended mode - proceed unless config says stop on warnings
            if [ "$BENTOBOX_STOP_ON_WARNINGS" = "true" ]; then
                echo "❌ Stopping due to warnings (BENTOBOX_STOP_ON_WARNINGS=true)"
                exit 1
            else
                echo "⚠️  Proceeding despite warnings (unattended mode)"
            fi
        fi
    fi
    
    # Run APT maintenance if needed
    source "$OMAKUB_PATH/install/apt-maintenance.sh"
else
    echo "⏭️  Pre-flight check skipped (BENTOBOX_SKIP_PREFLIGHT=true)"
fi

# For unattended mode, ensure gum is installed for potential post-install use
if [ "$BENTOBOX_MODE" != "interactive" ]; then
    echo "Using configuration from: $CONFIG_FILE"
    source "$OMAKUB_PATH/install/terminal/required/app-gum.sh" >/dev/null 2>&1 || true
fi

# Desktop software and tweaks will only be installed if we're running Gnome
# Check both XDG_CURRENT_DESKTOP (for direct sessions) and gnome-shell package (for SSH sessions)
if [[ "$XDG_CURRENT_DESKTOP" == *"GNOME"* ]] || command -v gnome-shell &> /dev/null; then
  # Ensure computer doesn't go to sleep or lock while installing
  if command -v gsettings &> /dev/null; then
    gsettings set org.gnome.desktop.screensaver lock-enabled false 2>/dev/null || true
    gsettings set org.gnome.desktop.session idle-delay 0 2>/dev/null || true
  fi

  echo "Installing terminal and desktop tools..."

  # Install terminal tools
  source "$OMAKUB_PATH/install/terminal.sh"

  # Install desktop tools and tweaks
  source "$OMAKUB_PATH/install/desktop.sh"

  # Revert to normal idle and lock settings
  if command -v gsettings &> /dev/null; then
    gsettings set org.gnome.desktop.screensaver lock-enabled true 2>/dev/null || true
    gsettings set org.gnome.desktop.session idle-delay 300 2>/dev/null || true
  fi
else
  echo "Only installing terminal tools..."
  source "$OMAKUB_PATH/install/terminal.sh"
fi
