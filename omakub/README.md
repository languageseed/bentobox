# Bentobox

**A curated Ubuntu 24.04+ development environment optimized for professional developers.**

Bentobox is a custom fork of [Omakub](https://github.com/basecamp/omakub) by DHH, tailored for modern development workflows with containerization, AI capabilities, and remote work tools.

## 🚀 Quick Start

Transform a fresh Ubuntu 24.04+ installation into a fully-configured development environment with a single command:

```bash
wget -qO- https://raw.githubusercontent.com/languageseed/bentobox/master/boot.sh | bash
```

That's it! The installation will guide you through selecting your preferred tools.

---

## ✨ What is Bentobox?

Bentobox takes the excellent foundation of Omakub and refines it for professional developers who need:

- 🐳 **Modern Container Management** - Portainer web UI instead of CLI tools
- 🤖 **Local AI Development** - OpenWebUI + Ollama for running LLMs locally
- 🌐 **Secure Remote Access** - Tailscale VPN for accessing your dev environment anywhere
- 🖱️ **Multi-Computer Workflows** - Barrier/Synergy for KVM sharing across machines
- 🎨 **Beautiful Wallpapers** - 7 curated Pexels wallpapers included
- 🎯 **Focused Tool Selection** - Streamlined to essential development tools

---

## 🆚 Bentobox vs Omakub

### What's Different?

| Feature | Omakub | Bentobox |
|---------|---------|----------|
| **Focus** | General purpose | Professional development |
| **Optional Apps** | 10+ choices | 4 focused choices |
| **Container UI** | lazydocker (CLI) | Portainer (Web UI) |
| **Databases** | MySQL/Redis/PostgreSQL | Removed (use containers as needed) |
| **AI Ready** | No | Yes (OpenWebUI + Ollama) |
| **Remote Access** | No | Yes (Tailscale built-in) |
| **KVM Sharing** | No | Yes (Barrier/Synergy) |
| **Entertainment** | Games, music apps | Removed for focus |

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
- **RAM**: 8GB minimum, 16GB recommended
- **Disk**: 30GB minimum, 50GB+ recommended (for AI models)
- **Network**: Internet connection required for installation

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

---

## 🛠️ Customization

Bentobox is built to be customizable. You can:

- Add your own wallpapers to `wallpaper/` directory
- Modify optional apps in `install/first-run-choices.sh`
- Add custom containers in `install/terminal/select-dev-storage.sh`
- Customize themes in `themes/` directory

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

Additional documentation available in the repository:

- `TESTING_GUIDE.md` - Complete testing procedures
- `wallpaper/LICENSE.md` - Wallpaper licensing and credits
- `wallpaper/README.md` - Wallpaper usage guide

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
