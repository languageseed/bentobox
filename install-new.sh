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

