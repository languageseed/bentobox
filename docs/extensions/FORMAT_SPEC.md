# Bentobox Extension Format Specification v1.0

## Overview

This document defines the standard format for extending Bentobox with new applications, themes, and customizations. Follow these conventions to ensure your extensions are automatically discovered and integrated.

---

## 1. Application Extensions

### 1.1 File Location

Place your application installation scripts in:
- **Terminal apps:** `install/terminal/app-{name}.sh`
- **Desktop apps:** `install/desktop/app-{name}.sh`
- **Optional apps:** `install/desktop/optional/app-{name}.sh`

### 1.2 Metadata Format

Add metadata as comments at the top of your script:

```bash
#!/bin/bash
# BENTOBOX_EXTENSION: v1
# NAME: Slack - Team Communication
# DESCRIPTION: Messaging and collaboration platform for teams
# CATEGORY: Communication
# ICON: slack
# HOMEPAGE: https://slack.com
# CHECK_COMMAND: slack
# REQUIRES: 
# CONFLICTS: 
# AUTHOR: Your Name
# VERSION: 1.0
```

### 1.3 Metadata Fields Reference

| Field | Required | Description | Example |
|-------|----------|-------------|---------|
| `BENTOBOX_EXTENSION` | ✅ Yes | Extension format version | `v1` |
| `NAME` | ✅ Yes | Display name for GUI/TUI | `Slack - Team Communication` |
| `DESCRIPTION` | ✅ Yes | Short description | `Messaging platform for teams` |
| `CATEGORY` | ✅ Yes | Category for grouping | `Communication`, `Development`, `Graphics`, `Productivity` |
| `ICON` | ⚪ Optional | Icon name (if available) | `slack` |
| `HOMEPAGE` | ⚪ Optional | Project website | `https://slack.com` |
| `CHECK_COMMAND` | ⚪ Optional | Command to verify installation | `slack` |
| `REQUIRES` | ⚪ Optional | Comma-separated prerequisites | `docker,nodejs` |
| `CONFLICTS` | ⚪ Optional | Conflicting packages | `skype,teams` |
| `AUTHOR` | ⚪ Optional | Extension author | `Your Name` |
| `VERSION` | ⚪ Optional | Extension version | `1.0` |

### 1.4 Script Structure

```bash
#!/bin/bash
# [METADATA BLOCK - see above]

# 1. Check if already installed (REQUIRED)
if command -v slack &> /dev/null; then
    echo "✓ Slack already installed, skipping..."
    exit 0
fi

# 2. Display installation message
echo "📦 Installing Slack..."

# 3. Perform installation
# Use appropriate package manager:
# - apt: sudo apt install -y package-name
# - snap: sudo snap install package-name
# - flatpak: flatpak install -y flathub org.package.Name
# - wget/curl: Download and install manually

sudo snap install slack --classic

# 4. Verify installation
if command -v slack &> /dev/null; then
    echo "✅ Slack installed successfully"
    exit 0
else
    echo "❌ Slack installation failed"
    exit 1
fi
```

### 1.5 Example: Complete Application Script

```bash
#!/bin/bash
# BENTOBOX_EXTENSION: v1
# NAME: Slack - Team Communication
# DESCRIPTION: Messaging and collaboration platform for teams
# CATEGORY: Communication
# ICON: slack
# HOMEPAGE: https://slack.com
# CHECK_COMMAND: slack
# REQUIRES: 
# CONFLICTS: 
# AUTHOR: Bentobox Community
# VERSION: 1.0

# Check if already installed
if command -v slack &> /dev/null; then
    echo "✓ Slack already installed, skipping..."
    exit 0
fi

echo "📦 Installing Slack..."

# Install via snap
sudo snap install slack --classic

# Verify installation
if command -v slack &> /dev/null; then
    echo "✅ Slack installed successfully"
    exit 0
else
    echo "❌ Slack installation failed"
    exit 1
fi
```

---

## 2. Theme Extensions

### 2.1 Directory Structure

Create a directory under `themes/` with your theme name:

```
themes/your-theme-name/
├── metadata.txt          # Theme metadata (REQUIRED)
├── gnome.sh             # GNOME settings (REQUIRED)
├── alacritty.toml       # Terminal colors (REQUIRED)
├── zellij.kdl           # Terminal multiplexer (REQUIRED)
├── btop.theme           # System monitor (REQUIRED)
├── neovim.lua           # Editor theme (REQUIRED)
├── vscode.sh            # VS Code theme (REQUIRED)
├── background.jpg       # Wallpaper (REQUIRED)
└── tophat.sh            # Tophat extension (OPTIONAL)
```

### 2.2 Metadata Format

**File:** `themes/your-theme-name/metadata.txt`

```ini
# BENTOBOX_THEME: v1
NAME: Dracula
DESCRIPTION: A dark theme for the masses
AUTHOR: Dracula Team
HOMEPAGE: https://draculatheme.com
VERSION: 1.0
COLORS: purple, pink, cyan, green
ACCENT: purple
STYLE: dark
SCREENSHOT: screenshot.png
```

### 2.3 Metadata Fields Reference

| Field | Required | Description | Example |
|-------|----------|-------------|---------|
| `BENTOBOX_THEME` | ✅ Yes | Theme format version | `v1` |
| `NAME` | ✅ Yes | Display name | `Dracula` |
| `DESCRIPTION` | ✅ Yes | Short description | `A dark theme for the masses` |
| `AUTHOR` | ⚪ Optional | Theme creator | `Dracula Team` |
| `HOMEPAGE` | ⚪ Optional | Theme website | `https://draculatheme.com` |
| `VERSION` | ⚪ Optional | Theme version | `1.0` |
| `COLORS` | ⚪ Optional | Primary colors | `purple, pink, cyan, green` |
| `ACCENT` | ⚪ Optional | Accent color | `purple` |
| `STYLE` | ⚪ Optional | `dark` or `light` | `dark` |
| `SCREENSHOT` | ⚪ Optional | Preview image filename | `screenshot.png` |

### 2.4 Theme File Templates

#### 2.4.1 gnome.sh (REQUIRED)

```bash
#!/bin/bash
# GNOME Desktop Environment settings

OMAKUB_THEME_COLOR="purple"  # Yaru color variant: red, orange, yellow, green, blue, purple, magenta
OMAKUB_THEME_BACKGROUND="your-theme-name/background.jpg"
source $OMAKUB_PATH/themes/set-gnome-theme.sh
```

#### 2.4.2 alacritty.toml (REQUIRED)

```toml
# Terminal colors for Alacritty

[colors.primary]
background = '#282a36'
foreground = '#f8f8f2'

[colors.normal]
black   = '#000000'
red     = '#ff5555'
green   = '#50fa7b'
yellow  = '#f1fa8c'
blue    = '#bd93f9'
magenta = '#ff79c6'
cyan    = '#8be9fd'
white   = '#bfbfbf'

[colors.bright]
black   = '#4d4d4d'
red     = '#ff6e67'
green   = '#5af78e'
yellow  = '#f4f99d'
blue    = '#caa9fa'
magenta = '#ff92d0'
cyan    = '#9aedfe'
white   = '#e6e6e6'
```

#### 2.4.3 zellij.kdl (REQUIRED)

```kdl
themes {
    your-theme-name {
        fg "#f8f8f2"
        bg "#282a36"
        black "#000000"
        red "#ff5555"
        green "#50fa7b"
        yellow "#f1fa8c"
        blue "#bd93f9"
        magenta "#ff79c6"
        cyan "#8be9fd"
        white "#bfbfbf"
        orange "#ffb86c"
    }
}
```

#### 2.4.4 btop.theme (REQUIRED)

```conf
# Btop system monitor theme

theme[main_bg]="#282a36"
theme[main_fg]="#f8f8f2"
theme[title]="#bd93f9"
theme[hi_fg]="#ff79c6"
theme[selected_bg]="#44475a"
theme[selected_fg]="#f8f8f2"
theme[inactive_fg]="#6272a4"
theme[graph_text]="#f8f8f2"
theme[meter_bg]="#44475a"
theme[proc_misc]="#8be9fd"
theme[cpu_box]="#bd93f9"
theme[mem_box]="#50fa7b"
theme[net_box]="#ffb86c"
theme[proc_box]="#ff79c6"
theme[div_line]="#6272a4"
theme[temp_start]="#50fa7b"
theme[temp_mid]="#f1fa8c"
theme[temp_end]="#ff5555"
theme[cpu_start]="#bd93f9"
theme[cpu_mid]="#ff79c6"
theme[cpu_end]="#ff5555"
theme[free_start]="#50fa7b"
theme[free_mid]="#f1fa8c"
theme[free_end]="#ff5555"
theme[cached_start]="#8be9fd"
theme[cached_mid]="#bd93f9"
theme[cached_end]="#ff79c6"
theme[available_start]="#ffb86c"
theme[available_mid]="#f1fa8c"
theme[available_end]="#ff5555"
theme[used_start]="#50fa7b"
theme[used_mid]="#f1fa8c"
theme[used_end]="#ff5555"
theme[download_start]="#50fa7b"
theme[download_mid]="#8be9fd"
theme[download_end]="#bd93f9"
theme[upload_start]="#ffb86c"
theme[upload_mid]="#ff79c6"
theme[upload_end]="#ff5555"
```

#### 2.4.5 neovim.lua (REQUIRED)

```lua
-- Neovim theme configuration
return {
  "your-theme-plugin/nvim",
  lazy = false,
  priority = 1000,
  config = function()
    vim.cmd([[colorscheme your-theme-name]])
  end,
}
```

#### 2.4.6 vscode.sh (REQUIRED)

```bash
#!/bin/bash
# VS Code theme installation

VSC_EXTENSION="your-publisher.your-theme"
VSC_THEME="Your Theme Name"
source $OMAKUB_PATH/themes/set-vscode-theme.sh
```

#### 2.4.7 background.jpg (REQUIRED)

- **Format:** JPEG or PNG
- **Recommended size:** 3840x2160 (4K) or 1920x1080 (Full HD)
- **File size:** Keep under 5MB for performance
- **Style:** Should match your theme's aesthetic

### 2.5 Example: Complete Theme

See `themes/tokyo-night/` for a reference implementation.

---

## 3. Language Extensions

### 3.1 File Location

`install/languages/{language-name}.sh`

### 3.2 Metadata Format

```bash
#!/bin/bash
# BENTOBOX_EXTENSION: v1
# NAME: Go
# DESCRIPTION: Go programming language
# CATEGORY: Programming Language
# ICON: go
# HOMEPAGE: https://go.dev
# CHECK_COMMAND: go
# REQUIRES: 
# CONFLICTS: 
# AUTHOR: Bentobox Community
# VERSION: 1.0
```

### 3.3 Script Structure

```bash
#!/bin/bash
# [METADATA BLOCK]

# Check if already installed
if command -v go &> /dev/null; then
    echo "✓ Go already installed, skipping..."
    exit 0
fi

echo "📦 Installing Go..."

# Install using mise (version manager)
mise use --global go@latest

# Verify installation
if command -v go &> /dev/null; then
    echo "✅ Go installed successfully"
    go version
    exit 0
else
    echo "❌ Go installation failed"
    exit 1
fi
```

---

## 4. Docker Container Extensions

### 4.1 File Location

`install/containers/{container-name}.sh`

### 4.2 Metadata Format

```bash
#!/bin/bash
# BENTOBOX_EXTENSION: v1
# NAME: n8n
# DESCRIPTION: Workflow automation tool
# CATEGORY: Automation
# ICON: n8n
# HOMEPAGE: https://n8n.io
# CHECK_COMMAND: docker ps | grep n8n
# REQUIRES: docker
# CONFLICTS: 
# AUTHOR: Your Name
# VERSION: 1.0
# DOCKER_IMAGE: n8nio/n8n
# DOCKER_PORT: 5678
```

### 4.3 Script Structure

```bash
#!/bin/bash
# [METADATA BLOCK]

# Check if Docker is available
if ! command -v docker &> /dev/null; then
    echo "❌ Docker not installed, skipping n8n..."
    exit 1
fi

# Check if container already exists
if docker ps -a --format '{{.Names}}' | grep -q '^n8n$'; then
    echo "✓ n8n container already exists, skipping..."
    exit 0
fi

echo "📦 Installing n8n container..."

# Create Docker volume for persistence
docker volume create n8n_data 2>/dev/null || true

# Run container
docker run -d \
    --name n8n \
    --restart unless-stopped \
    -p 5678:5678 \
    -v n8n_data:/home/node/.n8n \
    n8nio/n8n

# Verify installation
if docker ps --format '{{.Names}}' | grep -q '^n8n$'; then
    echo "✅ n8n installed successfully"
    echo "   Access at: http://localhost:5678"
    exit 0
else
    echo "❌ n8n installation failed"
    exit 1
fi
```

---

## 5. Desktop Customization Extensions

### 5.1 GNOME Extensions

**File:** `install/desktop/gnome-extension-{name}.sh`

```bash
#!/bin/bash
# BENTOBOX_EXTENSION: v1
# NAME: Clipboard Indicator
# DESCRIPTION: Clipboard management extension
# CATEGORY: GNOME Extension
# ICON: clipboard
# HOMEPAGE: https://extensions.gnome.org/extension/779/
# CHECK_COMMAND: gnome-extensions list | grep clipboard-indicator
# REQUIRES: 
# CONFLICTS: 
# AUTHOR: Your Name
# VERSION: 1.0
# GNOME_EXTENSION_ID: clipboard-indicator@tudmotu.com

# Check if GNOME is available
if [ -z "$DISPLAY" ] && [ -z "$WAYLAND_DISPLAY" ]; then
    echo "⚠️  No graphical session detected, skipping GNOME extension..."
    exit 0
fi

# Check if already installed
if gnome-extensions list 2>/dev/null | grep -q "clipboard-indicator@tudmotu.com"; then
    echo "✓ Clipboard Indicator already installed, skipping..."
    exit 0
fi

echo "📦 Installing Clipboard Indicator..."

# Install using gext
pipx install gnome-extensions-cli
gext install clipboard-indicator@tudmotu.com

# Enable extension
gnome-extensions enable clipboard-indicator@tudmotu.com

echo "✅ Clipboard Indicator installed successfully"
exit 0
```

### 5.2 Font Extensions

**File:** `install/desktop/font-{name}.sh`

```bash
#!/bin/bash
# BENTOBOX_EXTENSION: v1
# NAME: JetBrains Mono
# DESCRIPTION: Monospaced font for developers
# CATEGORY: Font
# ICON: font
# HOMEPAGE: https://www.jetbrains.com/lp/mono/
# CHECK_COMMAND: fc-list | grep -i "JetBrains Mono"
# REQUIRES: 
# CONFLICTS: 
# AUTHOR: Your Name
# VERSION: 1.0

# Check if already installed
if fc-list | grep -qi "JetBrains Mono"; then
    echo "✓ JetBrains Mono already installed, skipping..."
    exit 0
fi

echo "📦 Installing JetBrains Mono font..."

# Download font
FONT_URL="https://github.com/JetBrains/JetBrainsMono/releases/latest/download/JetBrainsMono.zip"
TEMP_DIR=$(mktemp -d)
cd $TEMP_DIR

wget -q $FONT_URL
unzip -q JetBrainsMono.zip -d JetBrainsMono

# Install to user fonts directory
mkdir -p ~/.local/share/fonts
cp JetBrainsMono/fonts/ttf/*.ttf ~/.local/share/fonts/

# Update font cache
fc-cache -f

# Cleanup
cd -
rm -rf $TEMP_DIR

# Verify installation
if fc-list | grep -qi "JetBrains Mono"; then
    echo "✅ JetBrains Mono installed successfully"
    exit 0
else
    echo "❌ JetBrains Mono installation failed"
    exit 1
fi
```

---

## 6. Categories Reference

Use these standard categories for consistency:

### Application Categories
- `Communication` - Chat, email, video conferencing
- `Development` - IDEs, editors, dev tools
- `Graphics` - Image editors, design tools
- `Productivity` - Office, notes, organization
- `Media` - Audio, video, streaming
- `Utilities` - System tools, file managers
- `Gaming` - Games and game platforms
- `Security` - Password managers, VPNs
- `Education` - Learning tools
- `Internet` - Browsers, downloaders

### Theme Categories
- Automatically categorized by directory structure

### Language Categories
- `Programming Language` - All programming languages

### Container Categories
- `Database` - PostgreSQL, MongoDB, Redis
- `Development` - Code servers, testing tools
- `Automation` - n8n, Jenkins
- `Monitoring` - Grafana, Prometheus
- `AI/ML` - Ollama, OpenWebUI
- `Management` - Portainer, Traefik

---

## 7. Testing Your Extension

### 7.1 Validation Checklist

- [ ] Metadata block is complete and properly formatted
- [ ] Script has executable permissions (`chmod +x`)
- [ ] Script checks if already installed (skip if present)
- [ ] Installation is idempotent (can be run multiple times safely)
- [ ] Script provides clear success/failure messages
- [ ] Exit code 0 for success, non-zero for failure
- [ ] All dependencies are documented in `REQUIRES` field
- [ ] Conflicts are documented in `CONFLICTS` field

### 7.2 Testing Commands

```bash
# Test script syntax
bash -n install/desktop/optional/app-yourapp.sh

# Test installation
bash install/desktop/optional/app-yourapp.sh

# Test idempotency (run again)
bash install/desktop/optional/app-yourapp.sh

# Verify component discovery
python3 install/orchestrator.py --list-components

# Test full installation with your extension
bash install.sh
```

---

## 8. Contributing Your Extension

### 8.1 File a Pull Request

1. Fork the Bentobox repository
2. Create your extension following this specification
3. Test your extension thoroughly
4. Commit with clear message: `Add [App Name] extension`
5. Submit pull request with:
   - Extension description
   - Screenshots (if applicable)
   - Testing notes

### 8.2 Extension Checklist

Include in your PR description:

```markdown
## Extension Information

- **Name:** Slack
- **Type:** Desktop Application
- **Category:** Communication
- **Tested on:** Ubuntu 24.04

## Checklist

- [x] Follows extension format specification v1.0
- [x] Metadata block is complete
- [x] Script is idempotent
- [x] Tested on fresh Ubuntu 24.04 installation
- [x] Documentation included (if needed)
- [x] No hardcoded paths (uses $OMAKUB_PATH, $HOME)
- [x] Proper error handling
- [x] Clear success/failure messages

## Testing Notes

Tested installation and uninstallation multiple times.
Verified it appears correctly in GUI and TUI menus.
```

---

## 9. Best Practices

### 9.1 Script Quality

1. **Always check if installed first**
   ```bash
   if command -v app &> /dev/null; then
       echo "✓ Already installed, skipping..."
       exit 0
   fi
   ```

2. **Use appropriate package managers**
   - `apt` for system packages
   - `snap` for snap packages
   - `flatpak` for Flatpak apps
   - `wget/curl` for manual downloads

3. **Handle errors gracefully**
   ```bash
   if some_command; then
       echo "✅ Success"
       exit 0
   else
       echo "❌ Failed"
       exit 1
   fi
   ```

4. **Provide informative output**
   - Use emojis for visual clarity: ✓ ✅ ❌ ⚠️ 📦 🚀
   - Show progress messages
   - Include relevant URLs or next steps

### 9.2 Theme Quality

1. **Provide complete color palette**
   - Cover all 16 terminal colors
   - Include proper contrast ratios
   - Test readability

2. **High-quality wallpaper**
   - Use appropriate resolution
   - Optimize file size
   - Match theme aesthetic

3. **Consistent styling**
   - All theme files should use same color palette
   - Maintain visual harmony across applications

### 9.3 Documentation

1. **Comment complex logic**
2. **Document prerequisites**
3. **Include usage notes if needed**

---

## 10. Examples

### 10.1 Minimal Application

```bash
#!/bin/bash
# BENTOBOX_EXTENSION: v1
# NAME: htop
# DESCRIPTION: Interactive process viewer
# CATEGORY: Utilities

if command -v htop &> /dev/null; then
    exit 0
fi

sudo apt install -y htop
```

### 10.2 Complex Application with Dependencies

```bash
#!/bin/bash
# BENTOBOX_EXTENSION: v1
# NAME: Mattermost Desktop
# DESCRIPTION: Team collaboration platform
# CATEGORY: Communication
# HOMEPAGE: https://mattermost.com
# CHECK_COMMAND: mattermost-desktop
# REQUIRES: 
# CONFLICTS: slack,discord
# AUTHOR: Community
# VERSION: 1.0

if command -v mattermost-desktop &> /dev/null; then
    echo "✓ Mattermost already installed"
    exit 0
fi

echo "📦 Installing Mattermost..."

# Add repository
wget -qO - https://deb.packages.mattermost.com/pubkey.gpg | sudo gpg --dearmor -o /usr/share/keyrings/mattermost-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/mattermost-archive-keyring.gpg] https://deb.packages.mattermost.com/ stable main" | sudo tee /etc/apt/sources.list.d/mattermost.list

# Update and install
sudo apt update
sudo apt install -y mattermost-desktop

if command -v mattermost-desktop &> /dev/null; then
    echo "✅ Mattermost installed successfully"
    exit 0
else
    echo "❌ Installation failed"
    exit 1
fi
```

---

## 11. Version History

- **v1.0** (2025-11-24) - Initial specification

---

## 12. Support

For questions or help with extensions:
- Open an issue on GitHub
- Join the community discussions
- Check existing extensions for examples

---

## License

This specification is part of Bentobox and is released under the MIT License.

