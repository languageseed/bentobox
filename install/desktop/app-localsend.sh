#!/bin/bash

# Check if already installed
if command -v localsend &> /dev/null; then
    echo "✓ LocalSend already installed, skipping..."
    exit 0
fi

# Temporarily disable exit on error for API call
set +e
cd /tmp
LOCALSEND_VERSION=$(curl -s "https://api.github.com/repos/localsend/localsend/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
set -e

if [ -z "$LOCALSEND_VERSION" ]; then
    echo "❌ Failed to fetch LocalSend version from GitHub API"
    echo "   Skipping LocalSend installation (may require manual install)"
    cd -
    exit 0
fi

if wget -O localsend.deb "https://github.com/localsend/localsend/releases/latest/download/LocalSend-${LOCALSEND_VERSION}-linux-x86-64.deb"; then
    sudo apt install -y ./localsend.deb || echo "⚠️  LocalSend installation failed"
    rm -f localsend.deb
else
    echo "❌ Failed to download LocalSend"
fi

cd -
