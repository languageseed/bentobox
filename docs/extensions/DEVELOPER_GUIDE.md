# Bentobox Extension Developer Guide

## Quick Start: Add Your First Extension in 5 Minutes

This guide shows you how to add new applications, themes, and customizations to Bentobox.

---

## Adding an Application

### Step 1: Create the Script

Create a file in the appropriate directory:
- Optional apps: `install/desktop/optional/app-{name}.sh`
- Terminal apps: `install/terminal/app-{name}.sh`
- Desktop apps: `install/desktop/app-{name}.sh`

### Step 2: Add Metadata

Start your script with this template:

```bash
#!/bin/bash
# BENTOBOX_EXTENSION: v1
# NAME: Your App Name - Short Description
# DESCRIPTION: Longer description of what this app does
# CATEGORY: Communication
# HOMEPAGE: https://yourapp.com
# CHECK_COMMAND: yourapp

# Check if already installed
if command -v yourapp &> /dev/null; then
    echo "✓ Your App already installed, skipping..."
    exit 0
fi

echo "📦 Installing Your App..."

# Install command (choose one):
# sudo apt install -y yourapp
# sudo snap install yourapp
# flatpak install -y flathub com.yourapp.App

sudo apt install -y yourapp

# Verify
if command -v yourapp &> /dev/null; then
    echo "✅ Your App installed successfully"
    exit 0
else
    echo "❌ Installation failed"
    exit 1
fi
```

### Step 3: Make Executable

```bash
chmod +x install/desktop/optional/app-yourapp.sh
```

### Step 4: Test It

```bash
# Test the script
bash install/desktop/optional/app-yourapp.sh

# Verify it appears in the system
python3 install/orchestrator.py --list-components | grep yourapp
```

**That's it!** Your app will now appear in the GUI and TUI automatically.

---

## Adding a Theme

### Step 1: Create Theme Directory

```bash
mkdir themes/your-theme-name
```

### Step 2: Create Metadata

```bash
cat > themes/your-theme-name/metadata.txt << 'EOF'
# BENTOBOX_THEME: v1
NAME: Your Theme Name
DESCRIPTION: A beautiful theme for productivity
AUTHOR: Your Name
COLORS: blue, purple, cyan
STYLE: dark
EOF
```

### Step 3: Create Required Files

Copy templates from an existing theme:

```bash
# Use Tokyo Night as template
cp themes/tokyo-night/gnome.sh themes/your-theme-name/
cp themes/tokyo-night/alacritty.toml themes/your-theme-name/
cp themes/tokyo-night/zellij.kdl themes/your-theme-name/
cp themes/tokyo-night/btop.theme themes/your-theme-name/
cp themes/tokyo-night/neovim.lua themes/your-theme-name/
cp themes/tokyo-night/vscode.sh themes/your-theme-name/
```

### Step 4: Customize Colors

Edit each file to use your theme's colors. For example:

**`alacritty.toml`:**
```toml
[colors.primary]
background = '#your-bg-color'
foreground = '#your-fg-color'

[colors.normal]
black   = '#000000'
red     = '#ff0000'
# ... etc
```

### Step 5: Add Wallpaper

```bash
cp your-wallpaper.jpg themes/your-theme-name/background.jpg
```

### Step 6: Update gnome.sh

```bash
#!/bin/bash
OMAKUB_THEME_COLOR="blue"  # Yaru color: red, orange, yellow, green, blue, purple
OMAKUB_THEME_BACKGROUND="your-theme-name/background.jpg"
source $OMAKUB_PATH/themes/set-gnome-theme.sh
```

**Done!** Your theme will appear in the Desktop Customization tab.

---

## Categories

Use these categories for your extensions:

### Applications
- `Communication` - Slack, Discord, Teams
- `Development` - IDEs, editors, Git clients
- `Graphics` - GIMP, Inkscape, Blender
- `Productivity` - Office suites, note apps
- `Media` - VLC, OBS, Audacity
- `Utilities` - File managers, system tools
- `Gaming` - Steam, Lutris, emulators
- `Security` - Password managers, VPNs
- `Education` - Learning platforms
- `Internet` - Browsers, download managers

---

## Real-World Examples

### Example 1: Slack

```bash
#!/bin/bash
# BENTOBOX_EXTENSION: v1
# NAME: Slack - Team Communication
# DESCRIPTION: Messaging and collaboration platform for teams
# CATEGORY: Communication
# HOMEPAGE: https://slack.com
# CHECK_COMMAND: slack

if command -v slack &> /dev/null; then
    echo "✓ Slack already installed, skipping..."
    exit 0
fi

echo "📦 Installing Slack..."
sudo snap install slack --classic

if command -v slack &> /dev/null; then
    echo "✅ Slack installed successfully"
    exit 0
else
    echo "❌ Slack installation failed"
    exit 1
fi
```

### Example 2: Telegram

```bash
#!/bin/bash
# BENTOBOX_EXTENSION: v1
# NAME: Telegram - Messaging App
# DESCRIPTION: Fast and secure messaging application
# CATEGORY: Communication
# HOMEPAGE: https://telegram.org
# CHECK_COMMAND: telegram-desktop

if command -v telegram-desktop &> /dev/null; then
    echo "✓ Telegram already installed, skipping..."
    exit 0
fi

echo "📦 Installing Telegram..."
sudo apt install -y telegram-desktop

if command -v telegram-desktop &> /dev/null; then
    echo "✅ Telegram installed successfully"
    exit 0
else
    echo "❌ Telegram installation failed"
    exit 1
fi
```

### Example 3: Postman

```bash
#!/bin/bash
# BENTOBOX_EXTENSION: v1
# NAME: Postman - API Development
# DESCRIPTION: API development and testing platform
# CATEGORY: Development
# HOMEPAGE: https://www.postman.com
# CHECK_COMMAND: postman

if command -v postman &> /dev/null; then
    echo "✓ Postman already installed, skipping..."
    exit 0
fi

echo "📦 Installing Postman..."
sudo snap install postman

if command -v postman &> /dev/null; then
    echo "✅ Postman installed successfully"
    exit 0
else
    echo "❌ Postman installation failed"
    exit 1
fi
```

---

## Testing Your Extension

### Local Testing

1. **Syntax check:**
```bash
bash -n install/desktop/optional/app-yourapp.sh
```

2. **Run the script:**
```bash
bash install/desktop/optional/app-yourapp.sh
```

3. **Test idempotency (run again):**
```bash
bash install/desktop/optional/app-yourapp.sh
# Should say "already installed"
```

4. **Check component discovery:**
```bash
python3 install/orchestrator.py --list-components
```

5. **Test in GUI:**
```bash
./bentobox-gui.sh
# Your app should appear in the Components tab
```

### On Test Machine

```bash
# Sync to test machine
rsync -avz bentobox/ user@testmachine:~/bentobox-test/

# SSH to test machine
ssh user@testmachine

# Run installation
cd ~/bentobox-test
bash install.sh
```

---

## Common Patterns

### Check for Different Command Names

```bash
if command -v app1 &> /dev/null || command -v app2 &> /dev/null; then
    echo "✓ Already installed"
    exit 0
fi
```

### Check for Installed Package (dpkg)

```bash
if dpkg -l | grep -q yourpackage; then
    echo "✓ Already installed"
    exit 0
fi
```

### Check for Snap Package

```bash
if snap list | grep -q yourapp; then
    echo "✓ Already installed"
    exit 0
fi
```

### Check for Flatpak App

```bash
if flatpak list --app | grep -q com.yourapp.App; then
    echo "✓ Already installed"
    exit 0
fi
```

### Check for Docker Container

```bash
if docker ps -a --format '{{.Names}}' | grep -q '^yourcontainer$'; then
    echo "✓ Container already exists"
    exit 0
fi
```

### Download and Install .deb Package

```bash
TEMP_DEB=$(mktemp)
wget -O $TEMP_DEB https://example.com/package.deb
sudo dpkg -i $TEMP_DEB
sudo apt-get install -f -y  # Fix dependencies
rm $TEMP_DEB
```

### Add PPA and Install

```bash
sudo add-apt-repository -y ppa:yourppa/ppa
sudo apt update
sudo apt install -y yourpackage
```

---

## Troubleshooting

### My extension doesn't appear in the GUI

**Solution:** Make sure you have the metadata header:
```bash
# BENTOBOX_EXTENSION: v1
# NAME: Your App Name
# DESCRIPTION: Description here
# CATEGORY: Communication
```

### Script fails silently

**Solution:** Add error checking:
```bash
set -e  # Exit on error
set -x  # Print commands (for debugging)
```

### Can't test on local machine

**Solution:** Use a VM or Docker:
```bash
# Using Docker
docker run -it ubuntu:24.04 /bin/bash
# Then copy your script and test
```

### Installation works but verification fails

**Solution:** Wait for PATH to update or refresh:
```bash
# Force PATH refresh
hash -r

# Or check specific path
if [ -f /usr/bin/yourapp ] || [ -f /usr/local/bin/yourapp ]; then
    echo "✅ Installed"
fi
```

---

## Best Practices

### ✅ Do This

- Always check if already installed first
- Use descriptive NAME and DESCRIPTION
- Provide clear success/failure messages
- Make scripts idempotent (can run multiple times)
- Use exit 0 for success, exit 1 for failure
- Test on clean Ubuntu 24.04 installation
- Use `command -v` instead of `which`
- Handle missing dependencies gracefully

### ❌ Don't Do This

- Don't use hardcoded paths (use $HOME, $OMAKUB_PATH)
- Don't assume interactive input
- Don't skip the "already installed" check
- Don't use `sudo` unnecessarily
- Don't forget to verify installation
- Don't use `exit` without a code
- Don't modify system files without backup

---

## File Template Generator

Use this script to generate a new extension:

```bash
#!/bin/bash
# generate-extension.sh

read -p "App name: " APP_NAME
read -p "Description: " APP_DESC
read -p "Category: " APP_CAT
read -p "Install command: " APP_CMD
read -p "Check command: " CHECK_CMD

FILENAME="install/desktop/optional/app-$(echo $APP_NAME | tr '[:upper:]' '[:lower:]' | tr ' ' '-').sh"

cat > "$FILENAME" << EOF
#!/bin/bash
# BENTOBOX_EXTENSION: v1
# NAME: $APP_NAME
# DESCRIPTION: $APP_DESC
# CATEGORY: $APP_CAT
# CHECK_COMMAND: $CHECK_CMD

if command -v $CHECK_CMD &> /dev/null; then
    echo "✓ $APP_NAME already installed, skipping..."
    exit 0
fi

echo "📦 Installing $APP_NAME..."

$APP_CMD

if command -v $CHECK_CMD &> /dev/null; then
    echo "✅ $APP_NAME installed successfully"
    exit 0
else
    echo "❌ $APP_NAME installation failed"
    exit 1
fi
EOF

chmod +x "$FILENAME"
echo "✅ Created: $FILENAME"
```

Usage:
```bash
bash generate-extension.sh
```

---

## Contributing Your Extensions

Once your extension is tested and working:

1. Fork the Bentobox repository
2. Add your extension
3. Commit with message: `Add [App Name] extension`
4. Open a pull request with:
   - Description of what it does
   - Screenshots (if GUI app)
   - Testing notes

We'll review and merge community extensions!

---

## Need Help?

- Check `EXTENSION_FORMAT_SPEC.md` for complete technical specification
- Look at existing extensions in `install/desktop/optional/` for examples
- Open an issue on GitHub
- Join community discussions

---

## Quick Reference

### Metadata Fields (Required)
```bash
# BENTOBOX_EXTENSION: v1
# NAME: Display name
# DESCRIPTION: What it does
# CATEGORY: Category name
```

### Metadata Fields (Optional)
```bash
# HOMEPAGE: https://example.com
# CHECK_COMMAND: appname
# REQUIRES: docker,nodejs
# CONFLICTS: other-app
# AUTHOR: Your Name
# VERSION: 1.0
# ICON: appname
```

### Script Structure
```bash
#!/bin/bash
# [METADATA]

# 1. Check if installed
if installed; then exit 0; fi

# 2. Install
echo "📦 Installing..."
install_command

# 3. Verify
if installed; then
    echo "✅ Success"
    exit 0
else
    echo "❌ Failed"
    exit 1
fi
```

---

**Happy Extending! 🚀**

