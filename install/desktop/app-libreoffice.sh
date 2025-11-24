#!/bin/bash

if command -v libreoffice &> /dev/null; then
    echo "✓ LibreOffice already installed, skipping..."
    exit 0
fi

# Work with Word, Excel, Powerpoint files
sudo apt install -y libreoffice
