# Bentobox

**A curated Ubuntu 24.04+ development environment with a beautiful GUI installer.**

Bentobox is a custom fork of [Omakub](https://github.com/basecamp/omakub) by DHH, optimized for professional developers with modern tools, AI capabilities, security hardening, and an intuitive graphical installer.

## 🚀 Quick Start

### Option 1: One-Line Installation (Terminal)

Transform a fresh Ubuntu 24.04+ installation with a single command:

```bash
wget -qO- https://raw.githubusercontent.com/languageseed/bentobox/master/boot.sh | bash
```

This will guide you through the installation with terminal prompts.

### Option 2: GUI Installer (Recommended)

For a visual, point-and-click experience, download and launch the GUI:

```bash
# Download Bentobox
wget -qO- https://raw.githubusercontent.com/languageseed/bentobox/master/boot.sh | bash

# Install GUI dependencies and launcher
cd ~/.local/share/omakub
bash install-gui.sh

# Launch the GUI (from Applications menu or terminal)
bentobox-gui
```

The GUI provides:
- 📦 Visual component selection
- 🎨 Desktop theme customization
- 🔒 Security configuration
- 🖼️ Wallpaper browser
- ▶️ Live installation progress
- 📊 Status dashboard

**Note:** After using the GUI to configure your preferences, click "Start Installation" to begin. You can also find "Bentobox" in your Applications menu after running `install-gui.sh`.

---

## ✨ What is Bentobox?

Bentobox takes the excellent foundation of Omakub and enhances it for professional developers who need:

- 🖥️ **Beautiful GUI Installer** - Point-and-click configuration with live progress
- 🔒 **Security Hardening** - UFW firewall, Fail2Ban, SSH hardening, automatic updates
- 🐳 **Modern Container Management** - Portainer web UI instead of CLI tools
- 🤖 **Local AI Development** - OpenWebUI + Ollama for running LLMs locally
- 🌐 **Secure Remote Access** - Tailscale VPN for accessing your dev environment anywhere
- 🪟 **Windows App Integration** - WinBoat for running Windows apps seamlessly on Linux
- 🎨 **Beautiful Themes** - 10+ curated themes with matching wallpapers
- 🎯 **Python Orchestration** - Robust installation with state management and error handling

---

## 🖥️ GUI Installer

Bentobox features a modern GTK-based graphical installer with 7 tabs:

### 👋 Welcome
- Overview of features
- Quick start instructions
- Direct link to component selection

### 📦 Components
Select from curated applications:
- **Desktop Apps**: 1Password, Cursor, Tailscale, Brave, Chrome, GIMP, OBS Studio, RubyMine, Sublime Text, WinBoat
- **Languages**: Node.js, Python, Ruby on Rails, Go, PHP, Elixir, Rust, Java
- **Containers**: Portainer, OpenWebUI, Ollama

### 🎨 Desktop
Customize your environment:
- **Themes**: Tokyo Night, Catppuccin, Everforest, Gruvbox, Kanagawa, Nord, Rose Pine, and more
- **Fonts**: Cascadia Code (Nerd Font), iA Writer Mono
- **GNOME Settings**: Configure shortcuts, extensions, and appearance
- **Quick Actions**: Apply themes and fonts instantly

### 🔒 Security
Optional security hardening:
- **Firewall**: Enable UFW with custom rules
- **System Hardening**: Automatic security updates, Fail2Ban, root login restrictions
- **SSH Security**: Key-only authentication, custom port
- **Privacy**: Disable error reporting and telemetry
- **Security Audit**: Check current security status

### 🖼️ Wallpapers
- Browse included wallpaper collection
- Preview thumbnails
- Apply wallpapers instantly

### ▶️ Install
- Live terminal output
- Clear completion message
- No annoying popups

### 📊 Status
- View installation state
- Component status overview
- Refresh on demand

### ⚙️ Maintenance
- Comprehensive uninstall option
- Triple confirmation for safety
- Complete system reset

---

## 🆚 Bentobox vs Omakub

### What's Different?

| Feature | Omakub | Bentobox |
|---------|---------|----------|
| **Installer** | Terminal only | GUI + Terminal |
| **Orchestration** | Pure Bash | Python + Bash |
| **Security Options** | No | Yes (UFW, Fail2Ban, SSH hardening) |
| **Focus** | General purpose | Professional development |
| **Container UI** | lazydocker (CLI) | Portainer (Web UI) |
| **Databases** | MySQL/Redis/PostgreSQL | Removed (use containers as needed) |
| **AI Ready** | No | Yes (OpenWebUI + Ollama) |
| **Remote Access** | No | Yes (Tailscale built-in) |
| **Windows Apps** | No | Yes (WinBoat - run Windows apps seamlessly) |
| **Themes** | 1 (Tokyo Night) | 10+ curated themes |
| **State Management** | No | Yes (resume failed installations) |

### Removed Applications

To maintain focus on development, we removed:
- Entertainment: Spotify, Steam, Minecraft
- Redundant tools: WhatsApp, Signal, Zoom, Dropbox
- Alternative editors: Doom Emacs, Windsurf, Zed
- Obsidian (note-taking)
- lazydocker (replaced with Portainer)

### Added Applications

- **Barrier** - Free, open-source KVM (keyboard/video/mouse) sharing
- **Tailscale** - Zero-config VPN for secure remote access
- **WinBoat** - Run Windows applications seamlessly on Linux (optional)
- **Sublime Text** - Fast, lightweight code editor with Package Control (optional)

### Container-First Approach

Instead of database containers (MySQL, Redis, PostgreSQL), Bentobox deploys:

- **Portainer** - Web-based Docker management UI
  - Access at `http://localhost:9000`
  - Manage all containers, images, volumes visually
  
- **OpenWebUI** - ChatGPT-like interface for local AI
  - Access at `http://localhost:3000`
  - Works with Ollama for privacy-focused AI development
  
- **Ollama** (Optional) - Run LLMs locally
  - Llama, Mistral, CodeLlama, and more
  - No internet required after model download

---

## 📦 What Gets Installed

### Always Installed

**Core Development Tools:**
- Docker & Docker Compose
- Git & GitHub CLI
- VS Code
- Neovim (LazyVim)
- Google Chrome
- Node.js, Ruby, or your chosen languages (via mise)

**Terminal Tools:**
- Alacritty (GPU-accelerated terminal)
- Zellij (terminal multiplexer)
- Modern CLI: fzf, ripgrep, bat, eza, zoxide
- btop (system monitor)
- fastfetch (system info)

**Desktop Applications:**
- LibreOffice (office suite)
- VLC (media player)
- Typora (Markdown editor)
- Pinta (image editor)
- LocalSend (file sharing)
- Flameshot (screenshots)

**Containers (Default):**
- Portainer - Docker management
- OpenWebUI - AI chat interface

### Optional (User Choice)

During installation, select from:
- **1Password** - Password manager
- **Barrier** - Free KVM sharing
- **Tailscale** - VPN for remote access
- **WinBoat** - Run Windows apps seamlessly (includes virt-manager, Docker, KVM)
- **Sublime Text** - Fast, lightweight code editor
- **Windows 10 ISO** - Pre-download Windows 10 for VM installations (~5.8 GB)

**Programming Languages:**
- Ruby on Rails
- Node.js
- Go
- PHP
- Python
- Elixir
- Rust
- Java

**Optional Container:**
- **Ollama** - Local LLM server

---

## 🎨 Custom Wallpapers

Bentobox includes 7 professionally curated wallpapers from [Pexels](https://www.pexels.com), automatically set up during installation:

- **Default**: Mountain landscape with dramatic sky
- 6 additional nature/landscape wallpapers
- All licensed under [Pexels License](https://www.pexels.com/license/) (free to use)
- Easy to switch via Settings → Appearance → Background

See `wallpaper/LICENSE.md` for full photographer credits and licensing details.

---

## 💻 System Requirements

- **OS**: Ubuntu 24.04+ (fresh installation recommended)
- **RAM**: 8GB minimum, 16GB recommended (20GB+ if using WinBoat)
- **Disk**: 30GB minimum, 50GB+ recommended (80GB+ if using WinBoat with Windows)
- **Network**: Internet connection required for installation
- **CPU**: Virtualization support (Intel VT-x/AMD-V) required for WinBoat

---

## 📖 Installation Guide

### 1. Fresh Ubuntu Installation

Start with a clean Ubuntu 24.04+ installation (desktop environment).

### 2. Run Installation Command

```bash
wget -qO- https://raw.githubusercontent.com/languageseed/bentobox/master/boot.sh | bash
```

### 3. Make Your Selections

The installer will prompt you to choose:

**Optional Apps** (select what you need):
- 1Password
- Barrier
- Tailscale
- WinBoat (Windows app integration)
- Sublime Text (code editor)
- Windows 10 ISO download

**Programming Languages** (select your stack):
- Ruby on Rails, Node.js, Python, Go, etc.

**Docker Containers** (defaults recommended):
- ✅ Portainer (Docker management)
- ✅ OpenWebUI (AI interface)
- ☐ Ollama (local LLM server)

### 4. Wait for Installation

Installation takes 15-30 minutes depending on your selections and internet speed.

### 5. Reboot

When prompted, reboot your system to apply all changes.

### 6. Access Your Tools

After reboot:
- **Portainer**: http://localhost:9000 (create admin account on first visit)
- **OpenWebUI**: http://localhost:3000
- **Ollama** (if installed): http://localhost:11434

---

## 🚀 Post-Installation

### Download AI Models (if Ollama installed)

```bash
# Pull a model (e.g., Llama 3.2)
docker exec -it ollama ollama pull llama3.2

# Smaller model for testing
docker exec -it ollama ollama pull llama3.2:1b

# Code-focused model
docker exec -it ollama ollama pull codellama

# List installed models
docker exec -it ollama ollama list
```

### Set Up Tailscale (if installed)

```bash
# Connect to Tailscale network
sudo tailscale up

# Get your Tailscale IP
tailscale ip

# Access your dev environment remotely
# From anywhere: http://YOUR-TAILSCALE-IP:9000 (Portainer)
```

### Configure Barrier (if installed)

1. Launch Barrier: `barrier`
2. Choose Server (computer with keyboard/mouse) or Client
3. Configure screen layout
4. Works great with Tailscale for remote KVM!

### Set Up WinBoat (if installed)

WinBoat lets you run Windows applications seamlessly on Linux - like "reverse WSL":

```bash
# Launch WinBoat GUI
winboat
# or from applications menu: search "WinBoat"
```

**First-Time Setup:**
1. WinBoat will automatically install Windows 10 (takes 20-30 min)
2. Once complete, the Guest API will show "Online"
3. Install your Windows apps and they'll appear in the WinBoat interface
4. Launch Windows apps directly - they integrate with your Linux desktop!

**Features:**
- Seamless filesystem integration (access Linux files from Windows)
- USB device passthrough
- Shared clipboard
- Native Linux window management for Windows apps

**Optional:** If you pre-downloaded the Windows 10 ISO, you can configure WinBoat to use it instead of downloading Windows again. See WinBoat settings.

**Tip:** Use virt-manager (installed with WinBoat) to manage the underlying Windows VM if needed.

---

## 🛠️ Customization & Extensions

Bentobox is built to be highly extensible. You can easily add your own applications, themes, and customizations!

### 🎁 Add Your Own Extensions

Bentobox uses a simple metadata-based system that makes it easy to add new packages:

```bash
# Copy the template
cp .templates/app-template.sh install/desktop/optional/app-slack.sh

# Edit metadata and installation commands
nano install/desktop/optional/app-slack.sh

# Make executable
chmod +x install/desktop/optional/app-slack.sh

# That's it! Your app will appear in the GUI automatically
```

### 📖 Extension Documentation

- **`EXTENSION_FORMAT_SPEC.md`** - Complete technical specification
- **`EXTENSION_DEVELOPER_GUIDE.md`** - Quick start guide with examples
- **`.templates/`** - Ready-to-use templates for apps and themes

### 🎨 Create Your Own Themes

```bash
# Create theme directory
mkdir themes/your-theme

# Copy template and reference files
cp .templates/theme-metadata.txt themes/your-theme/metadata.txt
cp themes/tokyo-night/* themes/your-theme/

# Customize colors and wallpaper
# Your theme will appear in the GUI automatically
```

### 🤝 Share Your Extensions

Created something useful? Share it with the community!
1. Test your extension thoroughly
2. Follow the extension format specification
3. Submit a pull request
4. Help others build better development environments

---

## 🆘 Troubleshooting

### Known Issues

#### Ulauncher Crashes on First Boot

**Symptom**: After installation and reboot, you see an error: "The application Ulauncher has closed unexpectedly."

**Why**: Ulauncher (the app launcher) sometimes crashes on first launch on fresh Ubuntu 24.04 installations. This is a known issue with Ulauncher's PPA package, not with Bentobox.

**Impact**: Cosmetic only - doesn't affect your system, Docker, or any other applications.

**Solution**:
1. **Quick Fix**: Click "Don't send" and check "Remember this in future". Ulauncher will restart automatically.
2. **If it persists**: Reboot the system - Ulauncher should work fine after reboot.
3. **Alternative**: Remove Ulauncher if you don't need it:
   ```bash
   sudo apt remove --purge ulauncher
   sudo apt autoremove
   ```

**Note**: Ulauncher is optional. Ubuntu has built-in app search (press `Super` key). You can safely remove Ulauncher without affecting other functionality.

#### GDM Login Screen Background

**Symptom**: Lock screen shows custom wallpaper, but GDM login screen (first boot/logout) shows default Ubuntu background.

**Why**: Ubuntu 24.04 uses compiled gresource files for GDM themes, making background customization complex. The dconf settings apply to lock screen but not the GDM greeter.

**Impact**: Minor cosmetic issue - lock screen and desktop wallpaper work correctly, only the initial login screen differs.

**Status**: Known limitation. We're working on a solution for Ubuntu 24.04's new GDM structure.

**Workaround**: Manually set using third-party tools after installation, or accept that login screen differs from desktop wallpaper.

---

### Installation Issues

```bash
# Check Docker is running
sudo systemctl status docker

# Check containers
docker ps

# View container logs
docker logs portainer
docker logs open-webui
```

### Portainer Not Accessible

```bash
# Check if port is listening
netstat -tlnp | grep 9000

# Restart container
docker restart portainer
```

### Wallpaper Not Set

```bash
# Check wallpapers exist
ls ~/.local/share/backgrounds/omakub/

# Manually set wallpaper
gsettings set org.gnome.desktop.background picture-uri "file://$HOME/.local/share/backgrounds/omakub/pexels-pok-rie-33563-2049422.jpg"
```

---

## 📚 Documentation

Comprehensive documentation is available in the `docs/` directory:

### Quick Links
- **[Documentation Index](docs/README.md)** - Complete documentation overview
- **[Extension System](docs/extensions/README.md)** - Add your own packages and themes
- **[Developer Guide](docs/extensions/DEVELOPER_GUIDE.md)** - Create extensions in 5 minutes
- **[Architecture Guide](docs/architecture/COMPARISON.md)** - Bentobox vs Omakub comparison
- **[Testing Guide](docs/development/TESTING_GUIDE.md)** - Testing procedures

### Feature Documentation
- **[GUI Guide](docs/features/GUI.md)** - Using the desktop installer
- **[Installation Modes](docs/features/INSTALLATION_MODES.md)** - Interactive, unattended, AI modes
- **[Themes](docs/features/THEMES.md)** - Theme system and customization
- **[Fonts](docs/features/FONTS.md)** - Font configuration
- **[Uninstall Guide](docs/features/UNINSTALL.md)** - Complete removal
- **[Troubleshooting](docs/troubleshooting/)** - Common issues and solutions

### WinBoat Documentation
- **[WinBoat Overview](docs/winboat/README.md)** - Run Windows apps on Linux
- **[WinBoat Testing](docs/winboat/TESTING_GUIDE.md)** - Testing procedures
- **[WinBoat Issues](docs/winboat/ISSUES.md)** - Known issues and workarounds
- **[WinBoat Integration](docs/winboat/INTEGRATION.md)** - Bentobox integration details

### Project-Specific Documentation
- **[Wallpaper Info](wallpaper/README.md)** - Wallpaper licensing and credits

---

## 🤝 Contributing

Bentobox is open source and contributions are welcome! Feel free to:

- Report issues
- Suggest improvements
- Submit pull requests
- Share your customizations

---

## 📜 License

Bentobox is released under the **MIT License** (inherited from Omakub).

**Wallpapers**: Licensed under the [Pexels License](https://www.pexels.com/license/) - free to use, modify, and distribute. See `wallpaper/LICENSE.md` for full details and photographer credits.

---

## 🙏 Credits

### Original Project
- **Omakub** by [DHH](https://github.com/dhh) and [contributors](https://github.com/basecamp/omakub/graphs/contributors)
- Repository: https://github.com/basecamp/omakub
- Website: https://omakub.org

### This Fork
- **Bentobox** by [languageseed](https://github.com/languageseed)
- Customized for professional development workflows
- Focus on containers, AI, and remote work

### Wallpapers
- All wallpapers from [Pexels](https://www.pexels.com)
- Photographers: Pok Rie, Eberhard Grossgasteiger, Felix Mittermeier, Philippe Donn
- Thank you to the Pexels community for making beautiful photography freely available

---

## 🌟 Why Bentobox?

The name "Bentobox" reflects our philosophy: a carefully curated selection of tools, each serving a specific purpose, arranged thoughtfully in a beautiful container. Like a Japanese bento box, we've chosen quality over quantity, creating a balanced and professional development environment.

---

## 🔗 Links

- **Installation**: `wget -qO- https://raw.githubusercontent.com/languageseed/bentobox/master/boot.sh | bash`
- **Repository**: https://github.com/languageseed/bentobox
- **Original Omakub**: https://github.com/basecamp/omakub
- **Issues**: https://github.com/languageseed/bentobox/issues

---

**Ready to get started?**

```bash
wget -qO- https://raw.githubusercontent.com/languageseed/bentobox/master/boot.sh | bash
```

Enjoy your perfectly curated Ubuntu development environment! 🎉

