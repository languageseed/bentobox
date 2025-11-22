# Omakub Review & Customization Guide

## Overview

**Omakub** is an opinionated Ubuntu setup script created by DHH (David Heinemeier Hansson) that transforms a fresh Ubuntu 24.04+ installation into a fully-configured web development environment with a single command.

- **License**: MIT (fully open source - you can fork and modify freely)
- **Primary Language**: Shell scripts (87.3%)
- **GitHub**: https://github.com/basecamp/omakub
- **Website**: https://omakub.org

## Architecture Overview

### Installation Flow

```
wget -qO- https://omakub.org/install | bash
  ↓
boot.sh (entry point)
  ↓
install.sh (main orchestrator)
  ├── check-version.sh (validates Ubuntu version)
  ├── first-run-choices.sh (interactive prompts)
  ├── identification.sh (git config)
  ├── terminal.sh (installs CLI tools)
  └── desktop.sh (installs GUI apps - only on GNOME)
```

### Key Components

#### 1. **Entry Point (`boot.sh`)**
- Shows ASCII art banner
- Validates Ubuntu 24.04+
- Clones the repo to `~/.local/share/omakub`
- Supports different branches via `OMAKUB_REF` env variable
- Kicks off `install.sh`

#### 2. **Main Installer (`install.sh`)**
- Error handling with retry instructions
- Checks Ubuntu distribution/version
- Presents interactive choices (using `gum` CLI tool)
- Detects if running GNOME (desktop environment)
- Installs terminal tools (always)
- Installs desktop tools (only on GNOME)

#### 3. **First-Run Choices (`install/first-run-choices.sh`)**
Users select:
- Optional desktop apps: 1Password, Spotify, Zoom, Dropbox
- Programming languages: Ruby, Node.js, Go, PHP, Python, Elixir, Rust, Java
- Databases: MySQL, Redis, PostgreSQL (via Docker)

#### 4. **Terminal Installation (`install/terminal.sh`)**
Loops through scripts in `install/terminal/` to install:
- Shell configurations (bash/zsh)
- Terminal emulator (Alacritty)
- CLI tools: btop, fastfetch, GitHub CLI, lazydocker, lazygit
- Text editor: Neovim
- Terminal multiplexer: Zellij
- Docker
- Version manager: mise (for language runtimes)
- Git configuration

#### 5. **Desktop Installation (`install/desktop.sh`)**
Loops through scripts in `install/desktop/` to install:
- Flatpak support
- GUI applications: Chrome, VS Code, Obsidian, Signal, VLC, etc.
- Fonts (JetBrains Mono, etc.)
- GNOME customizations: extensions, hotkeys, theme, dock settings
- Ulauncher (app launcher)
- Sets Alacritty as default terminal

## Directory Structure

```
omakub/
├── applications/          # Desktop application installers (.sh files)
├── bin/                   # Main omakub command & subcommands
│   └── omakub-sub/       # Subcommands: theme, font, update, etc.
├── configs/              # Configuration files to copy
│   ├── alacritty/        # Terminal emulator config
│   ├── neovim/           # Editor config
│   ├── typora/           # Markdown editor styles
│   ├── bashrc            # Bash configuration
│   ├── btop.conf         # System monitor config
│   ├── zellij.kdl        # Terminal multiplexer config
│   └── vscode.json       # VS Code settings
├── defaults/             # Default shell configs (aliases, functions, etc.)
│   └── bash/             # Bash-specific defaults
├── install/              # Installation scripts
│   ├── terminal/         # CLI tool installers
│   ├── desktop/          # GUI app installers
│   ├── first-run-choices.sh
│   └── identification.sh
├── migrations/           # Version migration scripts (timestamped)
├── themes/               # Color themes for all tools
│   ├── tokyo-night/
│   ├── gruvbox/
│   ├── catppuccin/
│   └── [8 more themes]
├── uninstall/            # Removal scripts for each app
├── boot.sh               # Entry point
├── install.sh            # Main orchestrator
└── version               # Current version number
```

## Key Design Patterns

### 1. **Modular Installation Scripts**
Each app/tool has its own installer script that:
- Can be run independently
- Is idempotent (safe to run multiple times)
- Follows naming convention: `app-{name}.sh`

Example: `install/terminal/docker.sh`
- Adds Docker apt repository
- Installs Docker and plugins
- Adds user to docker group
- Configures logging limits

### 2. **Configuration Management**
- Base configs in `configs/` directory
- Copied to user's home directory during installation
- Can be updated later via `omakub` command

### 3. **Theme System**
Each theme provides configs for all tools:
```
themes/tokyo-night/
├── alacritty.toml    # Terminal colors
├── btop.theme        # System monitor colors
├── gnome.sh          # GNOME shell theme script
├── neovim.lua        # Editor colors
├── vscode.sh         # VS Code theme script
├── zellij.kdl        # Multiplexer colors
└── background.jpg    # Wallpaper
```

Switching themes updates ALL tools at once for consistency.

### 4. **Interactive CLI (using `gum`)**
- Beautiful terminal UI for selections
- Multi-select with defaults
- Used throughout for user choices

### 5. **Version Management with `mise`**
Single tool to manage all programming language versions:
```bash
mise use --global ruby@latest
mise use --global node@lts
mise use --global python@latest
```

## How to Customize Omakub for Your Own Version

### Step 1: Fork the Repository
```bash
# On GitHub, click "Fork" button on https://github.com/basecamp/omakub
# Then clone your fork
git clone https://github.com/YOUR-USERNAME/omakub.git
cd omakub
```

### Step 2: Customize the Branding
```bash
# Edit boot.sh - change the ASCII art and name
nano boot.sh

# Update the repo URL to point to your fork
# Line 22: change basecamp/omakub to YOUR-USERNAME/YOUR-REPO-NAME
```

### Step 3: Modify Default Choices

**Edit `install/first-run-choices.sh`:**
```bash
# Change optional apps
OPTIONAL_APPS=("your-app-1" "your-app-2" "your-app-3")
DEFAULT_OPTIONAL_APPS='your-app-1,your-app-2'

# Change programming languages
AVAILABLE_LANGUAGES=("Python" "Node.js" "Rust")
SELECTED_LANGUAGES="Python,Node.js"

# Change databases
AVAILABLE_DBS=("PostgreSQL" "MongoDB")
SELECTED_DBS="PostgreSQL"
```

### Step 4: Add/Remove Applications

**To add a new terminal app:**
1. Create `install/terminal/app-yourapp.sh`
2. Write installation script:
```bash
#!/bin/bash

# Install via apt
sudo apt install -y yourapp

# Or download binary
wget -qO /tmp/yourapp https://example.com/yourapp
chmod +x /tmp/yourapp
sudo mv /tmp/yourapp /usr/local/bin/

# Or install via snap/flatpak
snap install yourapp
```

**To add a new desktop app:**
1. Create `install/desktop/app-yourapp.sh`
2. Follow similar pattern

**To remove an app:**
- Delete its installer script from `install/terminal/` or `install/desktop/`

### Step 5: Customize Configurations

**Modify default configs in `configs/` directory:**
- `configs/bashrc` - Shell aliases and functions
- `configs/alacritty.toml` - Terminal appearance
- `configs/neovim/` - Editor setup
- `configs/vscode.json` - VS Code settings

**Example: Add custom aliases**
Edit `configs/bashrc` or `defaults/bash/aliases`:
```bash
# Add your own aliases
alias mycommand='docker-compose'
alias dev='cd ~/projects && code .'
```

### Step 6: Customize Themes

**Option A: Modify existing theme**
```bash
cd themes/tokyo-night/
nano alacritty.toml  # Edit colors
nano neovim.lua      # Edit editor colors
```

**Option B: Add new theme**
```bash
mkdir themes/my-custom-theme
cd themes/my-custom-theme

# Create all theme files (copy from existing theme as template)
cp ../tokyo-night/alacritty.toml .
cp ../tokyo-night/btop.theme .
cp ../tokyo-night/gnome.sh .
cp ../tokyo-night/neovim.lua .
cp ../tokyo-night/vscode.sh .
cp ../tokyo-night/zellij.kdl .

# Add your wallpaper
cp ~/my-wallpaper.jpg background.jpg

# Then edit each file with your colors
```

### Step 7: Update Installation Entry Point

**Modify `boot.sh` to point to your repository:**
```bash
# Line 22-23:
git clone https://github.com/YOUR-USERNAME/YOUR-FORK.git ~/.local/share/omakub >/dev/null
```

### Step 8: Test Your Fork

**Local testing:**
```bash
# Don't run on your main system first!
# Use a VM or Docker container with Ubuntu 24.04

# Method 1: Test directly from local clone
cd ~/omakub
source install.sh

# Method 2: Test the full installation flow
bash -c "$(wget -qO- https://raw.githubusercontent.com/YOUR-USERNAME/YOUR-FORK/master/boot.sh)"
```

### Step 9: Create Your Own Install Command

**Host your own installer:**
```bash
# If you have a domain, create a redirect:
# yourdomain.com/install -> https://raw.githubusercontent.com/YOUR-USERNAME/YOUR-FORK/master/boot.sh

# Then users can install with:
wget -qO- https://yourdomain.com/install | bash

# Or directly from GitHub:
wget -qO- https://raw.githubusercontent.com/YOUR-USERNAME/YOUR-FORK/master/boot.sh | bash
```

## Common Customization Scenarios

### Scenario 1: Corporate/Team Setup
**Goal**: Standard dev environment for your team

Changes:
- Remove personal apps (Spotify, games, etc.)
- Add company-specific tools (VPN, internal CLI tools)
- Preconfigure Git with company email domain
- Add company-specific VS Code extensions
- Set up company code style configs

### Scenario 2: Minimal Setup
**Goal**: Lightweight installation

Changes:
- Remove `install/desktop.sh` entirely (terminal only)
- Keep only essential terminal tools
- Remove optional language installers
- Use lighter alternatives (e.g., vim instead of neovim)

### Scenario 3: Specific Language Focus
**Goal**: Python/Data Science workstation

Changes:
- Remove unused language options from first-run-choices
- Add Jupyter, pandas, numpy to Python installation
- Add data science apps (DBeaver, Tableau, etc.)
- Configure specialized tools (Anaconda, Poetry, etc.)

### Scenario 4: Gaming/Multimedia Setup
**Goal**: Entertainment + development

Changes:
- Add Steam, Discord, OBS, Audacity, GIMP
- Include gaming-specific drivers/tools
- Add RetroArch configuration
- Include multimedia codecs

## Advanced Customization Tips

### 1. **Add Pre/Post Install Hooks**
```bash
# Create install/hooks/pre-install.sh
#!/bin/bash
echo "Running pre-installation setup..."
# Your code here

# Create install/hooks/post-install.sh
#!/bin/bash
echo "Running post-installation cleanup..."
# Your code here

# Modify install.sh to call these hooks
```

### 2. **Environment-Specific Installation**
```bash
# Detect environment in install.sh
if [[ -f /etc/corporate-identifier ]]; then
  source ~/.local/share/omakub/install/corporate.sh
else
  source ~/.local/share/omakub/install/personal.sh
fi
```

### 3. **Config from Remote Source**
```bash
# Pull configs from your own dotfiles repo
git clone https://github.com/YOUR-USERNAME/dotfiles ~/.dotfiles
ln -sf ~/.dotfiles/.bashrc ~/.bashrc
ln -sf ~/.dotfiles/.vimrc ~/.vimrc
```

### 4. **Conditional Installation Based on Hardware**
```bash
# In an installer script
if lspci | grep -i nvidia; then
  # Install NVIDIA drivers
  sudo apt install -y nvidia-driver-535
fi

if [[ $(nproc) -ge 16 ]]; then
  # High-end machine, install heavy tools
  source install-heavy-ide.sh
fi
```

### 5. **User-Specific Overrides**
```bash
# After main installation, check for user overrides
if [[ -f ~/.omakub-overrides.sh ]]; then
  source ~/.omakub-overrides.sh
fi
```

## Maintaining Your Fork

### Staying Updated with Upstream
```bash
# Add upstream remote
git remote add upstream https://github.com/basecamp/omakub.git

# Fetch upstream changes
git fetch upstream

# Merge upstream changes
git checkout master
git merge upstream/master

# Resolve conflicts if any, then push
git push origin master
```

### Version Management
- Update the `version` file when you make significant changes
- Use `migrations/` folder for update scripts
- Name migration scripts with timestamps: `migrations/TIMESTAMP.sh`

### Testing Strategy
1. **VM Testing**: Use VirtualBox/VMware with Ubuntu 24.04
2. **Docker Testing**: Create Dockerfile with Ubuntu 24.04 base
3. **Live USB Testing**: Test on actual hardware without installing
4. **Staged Rollout**: Test on personal machine → team machines → company-wide

## Gotchas and Considerations

### 1. **Ubuntu Version Pinning**
- Omakub requires Ubuntu 24.04+
- Check version in `install/check-version.sh`
- Consider supporting other distros (Debian, Pop!_OS, etc.)

### 2. **Desktop Environment Detection**
- Currently optimized for GNOME
- KDE/XFCE would need different configs
- Check `$XDG_CURRENT_DESKTOP` variable

### 3. **Idempotency**
- Make sure scripts can run multiple times safely
- Check if software is already installed before installing
- Use `|| true` to ignore non-critical errors

### 4. **Network Dependencies**
- All downloads should be resumable
- Consider mirrors for faster downloads
- Handle offline scenarios gracefully

### 5. **Sudo Requirements**
- Many operations need sudo
- Consider using `sudo -v` at start to cache credentials
- Minimize sudo usage where possible

## File Locations Reference

After installation, Omakub files are located at:
- **Main installation**: `~/.local/share/omakub/`
- **Binary**: `~/.local/bin/omakub` (in PATH)
- **Configs**: Various locations in `~/` and `~/.config/`

## Post-Installation

Users can manage their installation with:
```bash
omakub              # Show menu
omakub theme        # Change theme
omakub font         # Change font
omakub update       # Update Omakub
omakub install      # Install additional apps
omakub uninstall    # Remove apps
```

## Resources

- **Original Repo**: https://github.com/basecamp/omakub
- **Official Site**: https://omakub.org
- **Manual**: Run `omakub manual` after installation
- **Extensions**: https://github.com/basecamp/omakub/blob/master/EXTENSIONS.md
- **Community Forks**: Search GitHub for "omakub fork"

## Recommended Next Steps

1. ✅ Fork the repository on GitHub
2. ✅ Clone your fork locally
3. ✅ Make a test branch: `git checkout -b customize-test`
4. ✅ Start with small changes (modify ASCII art, change defaults)
5. ✅ Test in a VM with Ubuntu 24.04
6. ✅ Document your changes in your fork's README
7. ✅ Create release tags for versioning
8. ✅ Share with your team/community

## Example: Quick Customization Checklist

- [ ] Change ASCII art in `boot.sh`
- [ ] Update repo URL in `boot.sh` (line 22)
- [ ] Modify default app selections in `install/first-run-choices.sh`
- [ ] Add your custom apps to `install/terminal/` or `install/desktop/`
- [ ] Customize shell aliases in `defaults/bash/aliases`
- [ ] Pick your favorite theme as the default
- [ ] Update README with your project name and goals
- [ ] Test in Ubuntu 24.04 VM
- [ ] Create GitHub release
- [ ] Set up your install command URL

---

Good luck with your customized Ubuntu setup! The MIT license gives you complete freedom to modify and distribute as you see fit.



