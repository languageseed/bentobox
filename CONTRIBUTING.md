# Contributing to Bentobox

Thank you for your interest in contributing to Bentobox! This guide will help you get started.

---

## 📂 Project Structure

```
bentobox/
├── README.md                    # Main project overview
├── boot.sh                     # Installation entry point
├── install.sh                  # Main installer (thin wrapper)
├── ascii.sh                    # Bentobox ASCII art
├── bentobox-gui.sh            # GUI launcher
├── version                     # Version identifier
│
├── docs/                       # 📚 All documentation
│   ├── README.md              # Documentation index
│   ├── architecture/          # Architecture docs
│   ├── development/           # Developer docs
│   ├── extensions/            # Extension system docs
│   ├── features/              # Feature-specific docs
│   └── troubleshooting/       # Troubleshooting guides
│
├── .templates/                # Extension templates
│   ├── README.md
│   ├── app-template.sh
│   └── theme-metadata.txt
│
├── install/                   # Installation scripts
│   ├── orchestrator.py       # Python orchestration
│   ├── gui.py                # GTK installer
│   ├── preflight-check.sh    # System validation
│   ├── terminal/             # Terminal tool installers
│   ├── desktop/              # Desktop app installers
│   │   └── optional/         # Optional app installers
│   ├── languages/            # Language installers
│   └── containers/           # Container installers
│
├── themes/                    # Theme files
│   ├── tokyo-night/
│   ├── gruvbox/
│   └── ... (10 themes total)
│
├── configs/                   # Configuration files
├── defaults/                  # Default configs
├── wallpaper/                 # Wallpapers
├── uninstall/                 # Uninstall scripts
├── migrations/                # Migration scripts
└── testing/                   # Testing resources
```

---

## 🚀 Types of Contributions

### 1. Add a New Application

The easiest way to contribute! Add support for a new application.

**Steps:**
1. Copy the template:
   ```bash
   cp .templates/app-template.sh install/desktop/optional/app-yourapp.sh
   ```

2. Edit metadata and installation commands

3. Test on Ubuntu 24.04

4. Submit pull request

**See:** [Extension Developer Guide](docs/extensions/DEVELOPER_GUIDE.md)

---

### 2. Add a New Theme

Contribute a beautiful theme for the community!

**Steps:**
1. Create theme directory:
   ```bash
   mkdir themes/your-theme
   ```

2. Copy template:
   ```bash
   cp .templates/theme-metadata.txt themes/your-theme/metadata.txt
   ```

3. Add theme files (see existing themes as reference)

4. Test the theme

5. Submit pull request

**See:** [Extension Format Spec](docs/extensions/FORMAT_SPEC.md)

---

### 3. Fix a Bug

Found a bug? Let's fix it!

**Steps:**
1. Open an issue (if not already open)
2. Fork the repository
3. Create a branch: `fix/bug-description`
4. Make your fix
5. Test thoroughly
6. Submit pull request

---

### 4. Improve Documentation

Documentation improvements are always welcome!

**Steps:**
1. Find the doc in `docs/` directory
2. Make your improvements
3. Follow [documentation standards](docs/README.md)
4. Submit pull request

---

### 5. Enhance Features

Want to add a new feature or improve an existing one?

**Steps:**
1. Open an issue to discuss the feature first
2. Get feedback from maintainers
3. Fork and implement
4. Test thoroughly
5. Document the feature
6. Submit pull request

---

## 📋 Contribution Guidelines

### Code Quality

- **Bash scripts:**
  - Use `#!/bin/bash` shebang
  - Check if already installed before installing
  - Provide clear success/failure messages
  - Use exit codes: 0 for success, non-zero for failure
  - Make scripts idempotent (safe to run multiple times)

- **Python code:**
  - Follow PEP 8 style guide
  - Add docstrings to functions
  - Handle errors gracefully
  - Use type hints where appropriate

### Testing

- Test on fresh Ubuntu 24.04 installation
- Test both interactive and unattended modes
- Verify installation is idempotent
- Check for conflicts with existing packages
- Test uninstall if applicable

### Documentation

- Update relevant docs in `docs/` directory
- Add examples where appropriate
- Keep language clear and concise
- Include screenshots for GUI changes

### Commit Messages

Follow this format:
```
Add [Feature/Fix]: Brief description

Longer explanation if needed.

- Bullet point 1
- Bullet point 2

Closes #123
```

**Examples:**
- `Add Slack extension`
- `Fix preflight check hanging over SSH`
- `Update GUI documentation with screenshots`
- `Improve theme auto-discovery`

---

## 🧪 Testing Your Changes

### Local Testing

```bash
# Test script syntax
bash -n install/desktop/optional/app-yourapp.sh

# Test installation
bash install/desktop/optional/app-yourapp.sh

# Test full installation
bash install.sh

# Test GUI
./bentobox-gui.sh
```

### Test on Fresh Ubuntu

**Using a VM:**
1. Create Ubuntu 24.04 VM
2. Copy your branch to the VM
3. Run installation
4. Verify everything works

**Using Docker:**
```bash
docker run -it ubuntu:24.04 /bin/bash
# Then test your installation
```

---

## 📝 Pull Request Process

### Before Submitting

- [ ] Code follows project standards
- [ ] Tested on Ubuntu 24.04
- [ ] Documentation updated
- [ ] Commit messages are clear
- [ ] No unrelated changes included

### PR Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] New application extension
- [ ] New theme
- [ ] Bug fix
- [ ] Feature enhancement
- [ ] Documentation update
- [ ] Other (please describe)

## Testing
- [ ] Tested on fresh Ubuntu 24.04
- [ ] Tested interactive mode
- [ ] Tested unattended mode (if applicable)
- [ ] Tested idempotency
- [ ] Tested uninstall (if applicable)

## Checklist
- [ ] Follows extension format (if adding extension)
- [ ] Documentation updated
- [ ] No breaking changes
- [ ] Screenshots included (if GUI change)

## Additional Notes
Any additional information reviewers should know
```

---

## 🎯 Extension Development

### Application Extension Checklist

- [ ] Metadata block complete (BENTOBOX_EXTENSION, NAME, DESCRIPTION, CATEGORY)
- [ ] Checks if already installed
- [ ] Installs using appropriate package manager
- [ ] Verifies installation succeeded
- [ ] Returns proper exit code
- [ ] Handles errors gracefully
- [ ] Works on fresh Ubuntu 24.04
- [ ] Is idempotent (can run multiple times)
- [ ] Clear success/failure messages

### Theme Extension Checklist

- [ ] `metadata.txt` with complete information
- [ ] `gnome.sh` with theme color
- [ ] `alacritty.toml` with terminal colors
- [ ] `zellij.kdl` with multiplexer theme
- [ ] `btop.theme` with system monitor theme
- [ ] `neovim.lua` with editor theme
- [ ] `vscode.sh` with VS Code theme
- [ ] `background.jpg` wallpaper (4K recommended)
- [ ] Colors are consistent across all files
- [ ] Theme looks good on actual system

---

## 🤝 Code of Conduct

### Our Standards

- Be respectful and inclusive
- Welcome newcomers
- Accept constructive criticism
- Focus on what's best for the community
- Show empathy towards others

### Not Acceptable

- Harassment or discrimination
- Trolling or insulting comments
- Public or private harassment
- Publishing others' private information
- Unprofessional conduct

---

## 💬 Communication

- **Issues:** Bug reports and feature requests
- **Discussions:** Questions and general discussion
- **Pull Requests:** Code contributions

---

## 📚 Additional Resources

- **[Extension System Overview](docs/extensions/README.md)**
- **[Extension Format Spec](docs/extensions/FORMAT_SPEC.md)**
- **[Developer Guide](docs/extensions/DEVELOPER_GUIDE.md)**
- **[Testing Guide](docs/development/TESTING_GUIDE.md)**
- **[Architecture Docs](docs/architecture/)**

---

## 🙏 Recognition

All contributors will be recognized in:
- GitHub contributors page
- Project credits
- Release notes (for significant contributions)

---

## ❓ Questions?

- Open an issue with the "question" label
- Start a discussion
- Check existing documentation

---

Thank you for contributing to Bentobox! Together we're building a better Ubuntu development environment. 🚀

