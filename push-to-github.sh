#!/bin/bash

# Script to commit and push all customizations to your bentobox fork

cd /Users/ben/Documents/bentobox/omakub

echo "🔍 Checking current status..."
git status

echo ""
echo "📝 Staging all changes..."
git add -A

echo ""
echo "💾 Creating commit..."
git commit -m "Custom bentobox fork: Professional dev environment

Removed apps (12):
- WhatsApp, Signal, Obsidian, Steam, lazydocker
- Spotify, Dropbox, Zoom, Doom Emacs, Minecraft, Windsurf, Zed

Added apps (3):
- Barrier (KVM sharing)
- Synergy (commercial KVM)
- Tailscale (VPN/remote access)

Container changes:
- Replaced MySQL/Redis/PostgreSQL with Portainer/OpenWebUI/Ollama
- Focus on modern container management and local AI

Customizations:
- Custom wallpaper collection (7 wallpapers)
- Default: pexels-pok-rie-33563-2049422.jpg
- Streamlined optional apps (only 4 choices)
- Professional development focus"

echo ""
echo "🔄 Pushing to GitHub fork..."
git push origin master

echo ""
echo "✅ Done! Your customizations are now on GitHub."
echo ""
echo "Your fork: https://github.com/languageseed/bentobox"
echo ""
echo "Next: Update boot.sh to point to your fork"

