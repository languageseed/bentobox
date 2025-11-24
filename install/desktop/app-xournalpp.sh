#!/bin/bash

if command -v xournalpp &> /dev/null; then
    echo "✓ Xournal++ already installed, skipping..."
    exit 0
fi

sudo apt install -y xournalpp
