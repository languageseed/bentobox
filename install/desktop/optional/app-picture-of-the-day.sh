#!/bin/bash

# Install Picture of the Day - Daily wallpaper from various sources
# https://flathub.org/en/apps/de.swsnr.pictureoftheday
# https://swsnr.de

# Exit if already installed via Flatpak
if flatpak list 2>/dev/null | grep -q "de.swsnr.pictureoftheday"; then
    echo "✓ Picture of the Day already installed, skipping..."
    exit 0
fi

echo "Installing Picture of the Day..."

# Install via Flatpak
flatpak install -y flathub de.swsnr.pictureoftheday || {
    echo "❌ Failed to install Picture of the Day via Flatpak"
    echo "   Make sure Flatpak is installed and Flathub is added"
    exit 0
}

echo "✅ Picture of the Day installed successfully"
echo ""
echo "💡 Picture of the Day features:"
echo "   • Automatic daily wallpaper updates"
echo "   • Multiple image sources:"
echo "     - NASA Astronomy Picture of the Day"
echo "     - Bing Image of the Day"
echo "     - Simon Stålenhag Artwork"
echo "     - Wikimedia Picture of the Day"
echo "     - NASA Earth Observatory Image of the Day"
echo "   • Preview images before applying"
echo "   • Pick your favorite source"
echo "   • Fresh wallpaper every day"
echo ""
echo "   Launch from Applications or run: flatpak run de.swsnr.pictureoftheday"
echo ""
echo "📝 Note: All images are copyrighted - check license terms for each image"
echo ""

exit 0

