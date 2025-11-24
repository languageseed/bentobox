#!/bin/bash
# Bentobox Config Parser
# Reads YAML config file and exports environment variables for installation
# Supports both interactive and unattended modes

# Determine config file location
if [ -n "$BENTOBOX_CONFIG" ]; then
    CONFIG_FILE="$BENTOBOX_CONFIG"
elif [ -f "$HOME/.bentobox-config.yaml" ]; then
    CONFIG_FILE="$HOME/.bentobox-config.yaml"
elif [ -f "$HOME/.bentobox-config.yml" ]; then
    CONFIG_FILE="$HOME/.bentobox-config.yml"
elif [ -f "$OMAKUB_PATH/bentobox-config.yaml" ]; then
    CONFIG_FILE="$OMAKUB_PATH/bentobox-config.yaml"
else
    CONFIG_FILE=""
fi

# Check if config exists and is readable
if [ -n "$CONFIG_FILE" ] && [ -f "$CONFIG_FILE" ]; then
    export BENTOBOX_MODE="unattended"
    echo "📋 Using config file: $CONFIG_FILE"
    
    # Simple YAML parser (works without dependencies)
    # This is intentionally simple - we control the YAML format
    
    # Parse user info
    export OMAKUB_USER_NAME=$(grep -A 2 "^user:" "$CONFIG_FILE" | grep "name:" | sed 's/.*name: *"\(.*\)".*/\1/')
    export OMAKUB_USER_EMAIL=$(grep -A 2 "^user:" "$CONFIG_FILE" | grep "email:" | sed 's/.*email: *"\(.*\)".*/\1/')
    
    # Parse optional apps (convert YAML list to space-separated)
    OPTIONAL_APPS=$(sed -n '/^desktop:/,/^[^ ]/ { /optional_apps:/,/^[^ ]*:/ { /- / { s/.*- //; s/ *#.*//; p } } }' "$CONFIG_FILE" | tr '\n' ' ' | sed 's/ $//')
    export OMAKUB_FIRST_RUN_OPTIONAL_APPS="$OPTIONAL_APPS"
    
    # Parse web apps
    WEB_APPS=$(sed -n '/web_apps:/,/^[^ ]*:/ { /- "/ { s/.*- "\(.*\)".*/\1/; p } }' "$CONFIG_FILE" | tr '\n' '\n')
    export OMAKUB_FIRST_RUN_WEB_APPS="$WEB_APPS"
    
    # Parse languages (join with newlines for gum compatibility)
    LANGUAGES=$(sed -n '/^languages:/,/^[^ ]/ { /- "/ { s/.*- "\(.*\)".*/\1/; p } }' "$CONFIG_FILE" | tr '\n' '\n')
    export OMAKUB_FIRST_RUN_LANGUAGES="$LANGUAGES"
    
    # Parse containers
    CONTAINERS=$(sed -n '/^containers:/,/^[^ ]/ { /- / { s/.*- //; s/ *#.*//; p } }' "$CONFIG_FILE" | tr '\n' '\n')
    export OMAKUB_FIRST_RUN_CONTAINERS="$CONTAINERS"
    
    # Parse theme
    THEME=$(grep "^  *theme:" "$CONFIG_FILE" | sed 's/.*theme: *//')
    export OMAKUB_THEME="$THEME"
    
    # Parse settings
    AUTO_REBOOT=$(grep "auto_reboot:" "$CONFIG_FILE" | sed 's/.*auto_reboot: *//')
    export BENTOBOX_AUTO_REBOOT="${AUTO_REBOOT:-false}"
    
    SKIP_CONFIRMATIONS=$(grep "skip_confirmations:" "$CONFIG_FILE" | sed 's/.*skip_confirmations: *//')
    export BENTOBOX_SKIP_CONFIRMATIONS="${SKIP_CONFIRMATIONS:-false}"
    
    VERBOSE=$(grep "verbose:" "$CONFIG_FILE" | sed 's/.*verbose: *//')
    export BENTOBOX_VERBOSE="${VERBOSE:-false}"
    
    WALLPAPER=$(grep "wallpaper:" "$CONFIG_FILE" | sed 's/.*wallpaper: *"\(.*\)".*/\1/')
    export BENTOBOX_WALLPAPER="$WALLPAPER"
    
    # Parse preflight settings
    SKIP_PREFLIGHT=$(grep "skip_preflight:" "$CONFIG_FILE" | sed 's/.*skip_preflight: *//')
    export BENTOBOX_SKIP_PREFLIGHT="${SKIP_PREFLIGHT:-false}"
    
    STOP_ON_WARNINGS=$(grep "stop_on_warnings:" "$CONFIG_FILE" | sed 's/.*stop_on_warnings: *//')
    export BENTOBOX_STOP_ON_WARNINGS="${STOP_ON_WARNINGS:-false}"
    
    AUTO_UPGRADE=$(grep "auto_upgrade:" "$CONFIG_FILE" | sed 's/.*auto_upgrade: *//')
    export BENTOBOX_AUTO_UPGRADE="${AUTO_UPGRADE:-false}"
    
    # Parse AI mode settings
    AI_MODE=$(grep "^mode:" "$CONFIG_FILE" | sed 's/.*mode: *//')
    if [ "$AI_MODE" = "ai" ]; then
        export BENTOBOX_AI_MODE="true"
        echo "🤖 AI Mode enabled"
    fi
    
    echo "✅ Configuration loaded"
    
    # Show what was configured (if verbose or AI mode)
    if [ "$BENTOBOX_VERBOSE" = "true" ] || [ "$BENTOBOX_AI_MODE" = "true" ]; then
        echo ""
        echo "Configuration Summary:"
        echo "  User: $OMAKUB_USER_NAME <$OMAKUB_USER_EMAIL>"
        echo "  Optional Apps: $OMAKUB_FIRST_RUN_OPTIONAL_APPS"
        echo "  Languages: $(echo "$OMAKUB_FIRST_RUN_LANGUAGES" | tr '\n' ', ' | sed 's/, $//')"
        echo "  Containers: $(echo "$OMAKUB_FIRST_RUN_CONTAINERS" | tr '\n' ', ' | sed 's/, $//')"
        [ -n "$OMAKUB_THEME" ] && echo "  Theme: $OMAKUB_THEME"
        echo ""
    fi
else
    export BENTOBOX_MODE="interactive"
    echo "💬 Interactive mode - will prompt for choices"
fi

