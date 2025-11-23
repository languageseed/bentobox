#!/bin/bash
# Sublime Text - Professional text editor

echo "Installing Sublime Text..."

# Add Sublime HQ GPG key and repository
if [ ! -f /etc/apt/sources.list.d/sublime-text.list ]; then
    wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/sublimehq-archive.gpg > /dev/null
    echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list
fi

# Install Sublime Text
sudo apt-get update -qq
sudo apt-get install -y sublime-text

echo "✅ Sublime Text installed"
echo "   Launch with: subl"

