# Bentobox Extension Templates

This directory contains templates to help you create new extensions for Bentobox.

## Available Templates

### 1. Application Template (`app-template.sh`)

Use this template to add new applications to Bentobox.

**Usage:**
```bash
# Copy template
cp .templates/app-template.sh install/desktop/optional/app-yourapp.sh

# Edit the file and replace all [bracketed] placeholders
nano install/desktop/optional/app-yourapp.sh

# Make executable
chmod +x install/desktop/optional/app-yourapp.sh

# Test it
bash install/desktop/optional/app-yourapp.sh
```

### 2. Theme Metadata Template (`theme-metadata.txt`)

Use this template to create theme metadata.

**Usage:**
```bash
# Create theme directory
mkdir themes/your-theme-name

# Copy template
cp .templates/theme-metadata.txt themes/your-theme-name/metadata.txt

# Edit metadata
nano themes/your-theme-name/metadata.txt

# Copy theme files from existing theme as starting point
cp themes/tokyo-night/*.{sh,toml,kdl,theme,lua,jpg} themes/your-theme-name/

# Customize colors in each file
```

## Quick Start

### Adding an Application

1. **Copy the template:**
   ```bash
   cp .templates/app-template.sh install/desktop/optional/app-slack.sh
   ```

2. **Edit the metadata** at the top:
   ```bash
   # BENTOBOX_EXTENSION: v1
   # NAME: Slack - Team Communication
   # DESCRIPTION: Messaging and collaboration platform
   # CATEGORY: Communication
   # CHECK_COMMAND: slack
   ```

3. **Add installation command:**
   ```bash
   sudo snap install slack --classic
   ```

4. **Update verification:**
   ```bash
   if command -v slack &> /dev/null; then
       echo "✅ Slack installed successfully"
       exit 0
   fi
   ```

5. **Make executable and test:**
   ```bash
   chmod +x install/desktop/optional/app-slack.sh
   bash install/desktop/optional/app-slack.sh
   ```

### Adding a Theme

1. **Create directory:**
   ```bash
   mkdir themes/dracula
   ```

2. **Copy template and existing theme files:**
   ```bash
   cp .templates/theme-metadata.txt themes/dracula/metadata.txt
   cp themes/tokyo-night/*.{sh,toml,kdl,theme,lua} themes/dracula/
   ```

3. **Edit metadata:**
   ```bash
   nano themes/dracula/metadata.txt
   ```

4. **Customize colors in each file:**
   - Edit `alacritty.toml` for terminal colors
   - Edit `zellij.kdl` for multiplexer colors
   - Edit `btop.theme` for system monitor colors
   - Edit `neovim.lua` for editor theme
   - Edit `vscode.sh` for VS Code theme
   - Update `gnome.sh` with your theme color

5. **Add wallpaper:**
   ```bash
   cp your-wallpaper.jpg themes/dracula/background.jpg
   ```

## Documentation

For complete documentation, see:
- `EXTENSION_FORMAT_SPEC.md` - Technical specification
- `EXTENSION_DEVELOPER_GUIDE.md` - Developer guide with examples

## Support

If you need help:
- Check existing extensions for examples
- Read the documentation files
- Open an issue on GitHub
- Join community discussions

## Contributing

Once your extension is complete and tested:
1. Test on fresh Ubuntu 24.04 installation
2. Ensure all metadata is complete
3. Submit a pull request
4. Include screenshots and testing notes

Thank you for contributing to Bentobox! 🚀

