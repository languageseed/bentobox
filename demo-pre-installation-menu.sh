#!/bin/bash
# Visual Demo of Pre-Installation Menu
# Shows what the TUI looks like with sample output

cat << 'EOF'

╔════════════════════════════════════════╗
║   Bentobox Installation Setup         ║
╚════════════════════════════════════════╝

Choose components to install on this system.
Pre-flight check will run next to detect conflicts.

━━━ Desktop Applications ━━━

 ◉ 1password
 ○ ASDControl
 ○ Audacity
 ○ Barrier
 ○ Brave
 ○ Cursor
 ○ Discord
 ○ GIMP
 ○ Mainline-Kernels
 ○ OBS-Studio
 ○ RetroArch
 ○ RubyMine
 ○ Sublime-Text
 ◉ Tailscale
 ○ VirtualBox
 ○ WinBoat
 ○ Windows

 Use ↑/↓ to navigate, Space to select, Enter to confirm

[After selecting Cursor and WinBoat...]

━━━ Programming Languages ━━━

 ○ Ruby on Rails
 ◉ Node.js
 ○ Go
 ○ PHP
 ◉ Python
 ○ Elixir
 ○ Rust
 ○ Java

 Use ↑/↓ to navigate, Space to select, Enter to confirm

━━━ Docker Containers ━━━

 ◉ Portainer
 ◉ OpenWebUI
 ○ Ollama

 Use ↑/↓ to navigate, Space to select, Enter to confirm

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✓ Component selection complete

Selected components:
  Desktop Apps: 1password, Tailscale, Cursor, WinBoat
  Languages: Node.js, Python
  Containers: Portainer, OpenWebUI

Next: Pre-flight check will scan for existing installations...

EOF

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "This is what the TUI menu looks like!"
echo ""
echo "To test it locally on leaf:"
echo "  1. Open a direct terminal on leaf (not SSH)"
echo "  2. rm ~/.bentobox-config.yaml"
echo "  3. cd ~/.local/share/omakub"
echo "  4. ./install.sh"
echo ""
echo "The menu will appear before pre-flight check."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

