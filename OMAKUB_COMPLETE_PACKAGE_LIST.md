# Omakub Complete Package Installation List

This is a comprehensive inventory of EVERYTHING that Omakub installs. Use this to decide what to remove from your custom fork.

---

## 🔧 CORE SYSTEM PACKAGES (Always Installed)

### Base Tools
- **curl** - Download tool
- **git** - Version control
- **unzip** - Archive extraction
- **gpg** - Encryption tool
- **wget** - Download tool

---

## 💻 TERMINAL/CLI APPLICATIONS (Always Installed)

### Essential CLI Tools
Located in: `install/terminal/apps-terminal.sh`
- **fzf** - Fuzzy finder for command line
- **ripgrep** (rg) - Fast text search tool
- **bat** - Cat clone with syntax highlighting
- **eza** - Modern ls replacement (colorized file listing)
- **zoxide** - Smarter cd command (jumps to frequent directories)
- **plocate** - Fast file locator
- **apache2-utils** - Apache utilities (includes htpasswd)
- **fd-find** - User-friendly find alternative

### System Monitoring & Info
- **btop** (`install/terminal/app-btop.sh`) - Beautiful system monitor
- **fastfetch** (`install/terminal/app-fastfetch.sh`) - System information tool

### Terminal Emulator
- **Alacritty** (`install/desktop/app-alacritty.sh`) - GPU-accelerated terminal

### Terminal Multiplexer
- **Zellij** (`install/terminal/app-zellij.sh`) - Modern terminal multiplexer (alternative to tmux)

### Text Editors
- **Neovim** (`install/terminal/app-neovim.sh`) - Modern vim
  - Includes: **luarocks**, **tree-sitter-cli**

### Version Control & Git
- **GitHub CLI (gh)** (`install/terminal/app-github-cli.sh`) - GitHub from command line

### Container Tools
- **Docker** (`install/terminal/docker.sh`) - Container platform
  - **docker-ce** - Docker Engine
  - **docker-ce-cli** - Docker CLI
  - **containerd.io** - Container runtime
  - **docker-buildx-plugin** - Build plugin
  - **docker-compose-plugin** - Compose plugin
  - **docker-ce-rootless-extras** - Rootless extras
- **lazydocker** (`install/terminal/app-lazydocker.sh`) - Terminal UI for Docker

### Git Tools
- **lazygit** (`install/terminal/app-lazygit.sh`) - Terminal UI for Git

### Version Manager
- **mise** (`install/terminal/mise.sh`) - Universal version manager (replaces asdf, nvm, rbenv, etc.)

### Interactive Prompts
- **gum** (`install/terminal/required/app-gum.sh`) - Tool for glamorous shell scripts

---

## 📚 DEVELOPMENT LIBRARIES (Always Installed)

Located in: `install/terminal/libraries.sh`

### Build Tools
- **build-essential** - C/C++ compiler and tools
- **pkg-config** - Manage compile/link flags
- **autoconf** - Generate configuration scripts
- **bison** - Parser generator
- **clang** - C/C++ compiler
- **rustc** - Rust compiler
- **pipx** - Install Python applications

### Development Libraries
- **libssl-dev** - OpenSSL development files
- **libreadline-dev** - Readline library
- **zlib1g-dev** - Compression library
- **libyaml-dev** - YAML parser library
- **libncurses5-dev** - Terminal UI library
- **libffi-dev** - Foreign Function Interface library
- **libgdbm-dev** - GNU database library
- **libjemalloc2** - Memory allocator

### Image Processing
- **libvips** - Fast image processing library
- **imagemagick** - Image manipulation suite
- **libmagickwand-dev** - ImageMagick development files
- **mupdf** - PDF viewer
- **mupdf-tools** - PDF tools

### Database Clients & Libraries
- **redis-tools** - Redis CLI client
- **sqlite3** - SQLite CLI client
- **libsqlite3-0** - SQLite library
- **libmysqlclient-dev** - MySQL client library
- **libpq-dev** - PostgreSQL client library
- **postgresql-client** - PostgreSQL CLI client
- **postgresql-client-common** - PostgreSQL common files

---

## 🗄️ DATABASES (User Selectable - Run in Docker)

Located in: `install/terminal/select-dev-storage.sh`

Default selections: MySQL, Redis

- **MySQL 8.4** - Relational database (port 3306)
- **Redis 7** - In-memory data store (port 6379)
- **PostgreSQL 16** - Relational database (port 5432)

**To Remove**: Modify `install/first-run-choices.sh` line 14-16

---

## 🎨 PROGRAMMING LANGUAGES (User Selectable)

Located in: `install/terminal/select-dev-language.sh`

Default selections: Ruby on Rails, Node.js

### Ruby on Rails
- **Ruby** (latest via mise)
- **Rails** gem

### Node.js
- **Node.js** (LTS via mise)

### Go
- **Go** (latest via mise)

### PHP
- **php**
- **php-curl**
- **php-apcu**
- **php-intl**
- **php-mbstring**
- **php-opcache**
- **php-pgsql**
- **php-mysql**
- **php-sqlite3**
- **php-redis**
- **php-xml**
- **php-zip**
- **Composer** (PHP package manager)

### Python
- **Python** (latest via mise)

### Elixir
- **Erlang** (latest via mise)
- **Elixir** (latest via mise)
- **Hex** (Elixir package manager)

### Rust
- **Rust** (via rustup)

### Java
- **Java** (latest via mise)

**To Remove**: Modify `install/first-run-choices.sh` lines 10-12

---

## 🖥️ DESKTOP APPLICATIONS (Always Installed on GNOME)

### Web Browsers
- **Google Chrome** (`install/desktop/app-chrome.sh`) - Web browser

### Text Editors & IDEs
- **Visual Studio Code** (`install/desktop/app-vscode.sh`) - Code editor

### Communication
- **Signal** (`install/desktop/app-signal.sh`) - Encrypted messaging

### Productivity
- **Obsidian** (`install/desktop/app-obsidian.sh`) - Note-taking (Markdown)
- **Typora** (`install/desktop/app-typora.sh`) - Markdown editor
- **LibreOffice** (`install/desktop/app-libreoffice.sh`) - Office suite

### File Sharing
- **LocalSend** (`install/desktop/app-localsend.sh`) - Cross-platform file sharing

### Media
- **VLC** (`install/desktop/app-vlc.sh`) - Media player

### Graphics
- **Pinta** (`install/desktop/app-pinta.sh`) - Image editor (Paint.NET alternative)
- **Xournal++** (`install/desktop/app-xournalpp.sh`) - PDF annotation and note-taking

### Screenshot Tools
- **Flameshot** (`install/desktop/app-flameshot.sh`) - Screenshot tool

### System Tools
- **GNOME Sushi** (`install/desktop/app-gnome-sushi.sh`) - File previewer (Spacebar preview)
- **GNOME Tweak Tool** (`install/desktop/app-gnome-tweak-tool.sh`) - Advanced GNOME settings
- **GNOME Extension Manager** (`install/desktop/set-gnome-extensions.sh`)
- **gnome-extensions-cli** (via pipx)
- **gir1.2-gtop-2.0** - System monitoring library
- **gir1.2-clutter-1.0** - Graphics library
- **Ulauncher** (`install/desktop/ulauncher.sh`) - Application launcher (like Spotlight/Alfred)

### Package Managers
- **Flatpak** (`install/desktop/a-flatpak.sh`) - Universal package manager
- **gnome-software-plugin-flatpak** - Flatpak integration for GNOME Software

### Clipboard
- **wl-clipboard** (`install/desktop/app-wl-clipboard.sh`) - Wayland clipboard utilities

---

## 🎯 OPTIONAL DESKTOP APPS (User Selectable)

Located in: `install/desktop/optional/`

Default selections: 1Password, Spotify, Zoom

### Password Managers
- **1Password** (`app-1password.sh`) - Password manager

### Media & Entertainment
- **Spotify** (`app-spotify.sh`) - Music streaming
- **Audacity** (`app-audacity.sh`) - Audio editing (via Flatpak)
- **RetroArch** (`app-retroarch.sh`) - Gaming emulator platform (via Flatpak)
- **Steam** (`app-steam.sh`) - Gaming platform
- **Minecraft** (`app-minecraft.sh`) - Game (includes OpenJDK 8)
- **OBS Studio** (`app-obs-studio.sh`) - Screen recording/streaming

### Communication
- **Zoom** (`app-zoom.sh`) - Video conferencing
- **Discord** (`app-discord.sh`) - Chat platform

### Cloud Storage
- **Dropbox** (`app-dropbox.sh`) - Cloud storage (includes nautilus-dropbox)

### Development Tools
- **Cursor** (`app-cursor.sh`) - AI code editor (includes fuse3, libfuse2t64)
- **Windsurf** (`app-windsurf.sh`) - Code editor
- **Zed** (`app-zed.sh`) - Code editor
- **RubyMine** (`app-rubymine.sh`) - Ruby IDE (via Snap)
- **Doom Emacs** (`app-doom-emacs.sh`) - Emacs distribution (includes emacs)

### Graphics
- **GIMP** (`app-gimp.sh`) - Advanced image editor (via Flatpak)

### Browsers
- **Brave** (`app-brave.sh`) - Privacy-focused browser

### System Tools
- **VirtualBox** (`app-virtualbox.sh`) - Virtual machine manager (includes virtualbox-ext-pack)
- **Mainline Kernels** (`app-mainline-kernels.sh`) - Kernel update tool

**To Remove**: Modify `install/first-run-choices.sh` lines 5-7

---

## 🔧 OPTIONAL TERMINAL APPS (Not Selected by Default)

Located in: `install/terminal/optional/`

These are NOT installed by default but available:

- **Geekbench** (`app-geekbench.sh`) - System benchmark tool
- **Ollama** (`app-ollama.sh`) - Local LLM runner
- **Tailscale** (`app-tailscale.sh`) - VPN/network tool

---

## 🎨 FONTS (Always Installed)

Located in: `install/desktop/fonts.sh`

- **CascadiaMono Nerd Font** - Coding font with icons
- **iA Writer Mono** - Clean monospace font

---

## 🖼️ GNOME SHELL EXTENSIONS (Always Installed on GNOME)

Located in: `install/desktop/set-gnome-extensions.sh`

Extensions are installed but you need to check the actual script for the specific list. The system installs:
- Extension Manager tool
- Various shell extensions for productivity

---

## 📱 WEB APPLICATIONS (Optional)

Located in: `install/desktop/optional/select-web-apps.sh` and `applications/`

These create desktop shortcuts for web apps:
- **Basecamp** - Project management
- **HEY** - Email service
- **WhatsApp** - Messaging
- **Activity** - (likely a 37signals product)

---

## 🎭 THEMES (10 Available)

Located in: `themes/`

One theme selected during installation:
- Tokyo Night (default feel)
- Gruvbox
- Catppuccin
- Everforest
- Kanagawa
- Nord
- Rose Pine
- Matte Black
- Osaka Jade
- Ristretto

Each theme includes configurations for:
- Alacritty (terminal colors)
- btop (system monitor colors)
- GNOME (shell theme)
- Neovim (editor colors)
- VS Code (editor theme)
- Zellij (multiplexer colors)
- Desktop wallpaper

---

## 📝 CONFIGURATION FILES

Located in: `configs/` and `defaults/`

### Shell Configuration
- **bashrc** - Bash configuration
- **inputrc** - Readline configuration
- Bash aliases, functions, and prompts

### Application Configs
- **alacritty.toml** - Terminal settings
- **btop.conf** - System monitor settings
- **fastfetch.jsonc** - System info display
- **neovim/** - Editor config (LazyVim-based)
- **vscode.json** - VS Code settings
- **zellij.kdl** - Multiplexer config
- **xcompose** - Custom keyboard compositions
- **ulauncher.json** - Launcher settings
- **typora/** - Markdown editor styles

---

## 🗑️ HOW TO REMOVE ITEMS

### Method 1: Delete Installer Scripts
Simply delete the `.sh` file for any app you don't want:

```bash
# Example: Remove Spotify
rm install/desktop/optional/app-spotify.sh

# Example: Remove Docker
rm install/terminal/docker.sh

# Example: Remove Chrome
rm install/desktop/app-chrome.sh
```

### Method 2: Modify Selection Lists
Edit `install/first-run-choices.sh`:

```bash
# Remove optional apps from choices (lines 5-7)
OPTIONAL_APPS=("1password" "Zoom")  # Removed Spotify, Dropbox
DEFAULT_OPTIONAL_APPS='1password'

# Remove languages from choices (lines 10-12)
AVAILABLE_LANGUAGES=("Node.js" "Python")  # Only keep these
SELECTED_LANGUAGES="Node.js,Python"

# Remove databases from choices (lines 14-16)
AVAILABLE_DBS=("PostgreSQL")  # Only PostgreSQL
SELECTED_DBS="PostgreSQL"
```

### Method 3: Remove Entire Categories

**Remove ALL optional desktop apps:**
```bash
rm -rf install/desktop/optional/
```

**Remove ALL language support:**
```bash
rm install/terminal/select-dev-language.sh
```

**Remove ALL database support:**
```bash
rm install/terminal/select-dev-storage.sh
```

**Remove Docker entirely:**
```bash
rm install/terminal/docker.sh
rm install/terminal/app-lazydocker.sh
```

### Method 4: Skip Desktop Installation
To create a terminal-only installation, edit `install.sh` and remove the desktop section entirely (lines 19-35).

---

## 📊 PACKAGE COUNT SUMMARY

| Category | Count | Required? |
|----------|-------|-----------|
| Core system tools | 5 | Yes |
| Essential CLI tools | 8 | Yes |
| Terminal apps | 8 | Yes |
| Development libraries | 30+ | Yes |
| Desktop apps (always) | 17 | On GNOME |
| Optional desktop apps | 20+ | User choice |
| Optional terminal apps | 3 | No |
| Programming languages | 8 | User choice |
| Databases | 3 | User choice |
| Fonts | 2 | On GNOME |
| Themes | 10 | Choose 1 |

**Total: 100+ packages/applications**

---

## 🎯 RECOMMENDED MINIMAL SETUP

If you want a truly minimal installation, keep only:

### Terminal
- curl, git, unzip, wget
- fzf, ripgrep, bat, eza, zoxide
- neovim
- docker (if you need containers)
- mise + 1-2 programming languages

### Desktop (if needed)
- Alacritty (terminal)
- VS Code or Cursor (editor)
- Chrome or Firefox (browser)
- Your choice of 2-3 essential apps

This would reduce the installation from ~100 packages to ~20 packages.

---

## 💡 TIPS

1. **Start minimal**: Remove everything, then add back only what you need
2. **Test in VM**: Always test your custom fork in a VM first
3. **Document changes**: Keep a changelog of what you removed/added
4. **Check dependencies**: Some apps depend on libraries (e.g., Neovim needs luarocks)
5. **Consider alternatives**: 
   - Use Firefox instead of Chrome
   - Use micro/nano instead of Neovim
   - Use tmux instead of Zellij
   - Use regular Emacs instead of Doom Emacs

---

## 📞 NEXT STEPS

Ready to customize? Here's your workflow:

1. ✅ Review this list and mark what you want to remove
2. ✅ Fork the repository
3. ✅ Delete installer scripts for unwanted apps
4. ✅ Modify `install/first-run-choices.sh` for new defaults
5. ✅ Test in Ubuntu 24.04 VM
6. ✅ Deploy to your actual system

Good luck customizing your perfect Ubuntu setup!



