#!/bin/bash

# Install Planify - Task manager with Todoist, Nextcloud & CalDAV support
# https://github.com/alainm23/planify
# https://useplanify.com/

# Exit if already installed via Flatpak
if flatpak list 2>/dev/null | grep -q "io.github.alainm23.planify"; then
    echo "✓ Planify already installed, skipping..."
    exit 0
fi

echo "Installing Planify..."

# Install via Flatpak
flatpak install -y flathub io.github.alainm23.planify || {
    echo "❌ Failed to install Planify via Flatpak"
    echo "   Make sure Flatpak is installed and Flathub is added"
    exit 0
}

echo "✅ Planify installed successfully"
echo ""
echo "💡 Planify features:"
echo "   • Modern, intuitive task manager designed for GNOME"
echo "   • Todoist integration with full sync"
echo "   • Nextcloud & CalDAV support"
echo "   • Drag & drop task organization"
echo "   • Calendar integration"
echo "   • Recurring tasks and reminders"
echo "   • Dark mode support"
echo "   • Offline mode with cloud sync"
echo "   • Labels, filters, and attachments"
echo ""
echo "   Launch from Applications or run: flatpak run io.github.alainm23.planify"
echo ""
echo "📝 Note: Made with 💗 in Perú - Not affiliated with Doist"
echo ""

exit 0

