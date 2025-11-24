# Bentobox Documentation

Welcome to the Bentobox documentation! This directory contains all technical documentation, guides, and resources.

---

## 📚 Quick Links

### Getting Started
- **[Main README](../README.md)** - Project overview and installation
- **[Installation Modes](features/INSTALLATION_MODES.md)** - Interactive, unattended, and AI modes
- **[Pre-Installation Menu](features/PRE_INSTALLATION_MENU.md)** - Component selection guide

### For Users
- **[GUI Guide](features/GUI.md)** - Using the desktop installer
- **[Themes](features/THEMES.md)** - Available themes and customization
- **[Fonts](features/FONTS.md)** - Font configuration and troubleshooting
- **[Uninstall](features/UNINSTALL.md)** - How to remove Bentobox

### For Developers
- **[Extension System](extensions/README.md)** - Add your own packages and themes
- **[Extension Format](extensions/FORMAT_SPEC.md)** - Technical specification
- **[Developer Guide](extensions/DEVELOPER_GUIDE.md)** - Quick start tutorial
- **[Testing Guide](development/TESTING_GUIDE.md)** - How to test Bentobox

### Architecture
- **[Architecture Comparison](architecture/COMPARISON.md)** - Bentobox vs Omakub
- **[Architecture Diagrams](architecture/DIAGRAMS.md)** - Visual architecture
- **[Code Usage Analysis](development/CODE_USAGE_ANALYSIS.md)** - What's from Omakub

---

## 📖 Documentation Structure

```
docs/
├── README.md (this file)
│
├── architecture/           # System architecture
│   ├── COMPARISON.md      # Bentobox vs Omakub
│   ├── DIAGRAMS.md        # Visual diagrams
│   └── IMPROVEMENTS.md    # Architectural improvements
│
├── development/            # Developer documentation
│   ├── CODE_USAGE_ANALYSIS.md  # Code breakdown
│   └── TESTING_GUIDE.md        # Testing procedures
│
├── extensions/             # Extension system (⭐ Community)
│   ├── README.md           # Extension system overview
│   ├── FORMAT_SPEC.md      # Technical specification
│   ├── DEVELOPER_GUIDE.md  # Quick start guide
│   ├── EXTENSIBILITY_ANALYSIS.md  # Current state
│   └── EXAMPLES.md         # Extension examples
│
├── features/               # Feature documentation
│   ├── AUTO_ADJUSTMENT.md          # Auto-skip installed packages
│   ├── DESKTOP_CUSTOMIZATION.md   # Desktop customization tab
│   ├── FONTS.md                    # Font configuration
│   ├── GUI.md                      # GUI installer guide
│   ├── INSTALLATION_MODES.md      # Installation modes
│   ├── PREFLIGHT_CHECK.md         # Pre-flight validation
│   ├── PRE_INSTALLATION_MENU.md   # Component selection
│   ├── THEMES.md                   # Theme system
│   ├── TUI_OVER_SSH.md            # Terminal UI over SSH
│   └── UNINSTALL.md               # Uninstall system
│
├── troubleshooting/        # Troubleshooting guides
│   └── GUI_TROUBLESHOOTING.md  # GUI-specific issues
│
└── winboat/                # WinBoat documentation
    ├── README.md           # Overview and quick start
    ├── DEPLOYMENT.md       # Deployment notes
    ├── EVALUATION.md       # Evaluation results
    ├── INTEGRATION.md      # Bentobox integration
    ├── ISSUES.md           # Known issues
    └── TESTING_GUIDE.md    # Testing procedures
```

---

## 🚀 Common Tasks

### Install Bentobox
```bash
wget -qO- https://raw.githubusercontent.com/languageseed/bentobox/master/boot.sh | bash
```

### Add a New Application
See **[Developer Guide](extensions/DEVELOPER_GUIDE.md)**
```bash
cp .templates/app-template.sh install/desktop/optional/app-yourapp.sh
# Edit, test, done!
```

### Create a New Theme
See **[Extension Format](extensions/FORMAT_SPEC.md)**
```bash
mkdir themes/your-theme
cp .templates/theme-metadata.txt themes/your-theme/metadata.txt
# Add theme files
```

### Test Your Changes
See **[Testing Guide](development/TESTING_GUIDE.md)**
```bash
bash install.sh
```

### Uninstall Bentobox
See **[Uninstall Guide](features/UNINSTALL.md)**
```bash
bash ~/.local/share/omakub/install/uninstall-bentobox.sh
```

---

## 🎯 By Role

### For Users
- Start with the **[Main README](../README.md)**
- Check out **[GUI Guide](features/GUI.md)**
- Learn about **[Themes](features/THEMES.md)**
- Want Windows apps? **[WinBoat Guide](winboat/README.md)**
- If issues: **[Troubleshooting](troubleshooting/)**

### I'm a Developer/Contributor
- Read **[Architecture Comparison](architecture/COMPARISON.md)**
- Understand the **[Extension System](extensions/README.md)**
- Follow **[Developer Guide](extensions/DEVELOPER_GUIDE.md)**
- Use **[Testing Guide](development/TESTING_GUIDE.md)**

### I Want to Extend Bentobox
- **[Extension System Overview](extensions/README.md)** - Start here!
- **[Extension Format Spec](extensions/FORMAT_SPEC.md)** - Technical details
- **[Developer Guide](extensions/DEVELOPER_GUIDE.md)** - Step-by-step tutorial
- **[Examples](extensions/EXAMPLES.md)** - Real-world examples

### I Want to Understand the Code
- **[Code Usage Analysis](development/CODE_USAGE_ANALYSIS.md)** - What's from Omakub
- **[Architecture Comparison](architecture/COMPARISON.md)** - Design decisions
- **[Architecture Diagrams](architecture/DIAGRAMS.md)** - Visual overview

---

## 📝 Documentation Standards

### File Naming
- Use `SCREAMING_SNAKE_CASE.md` for documentation files
- Be descriptive: `EXTENSION_FORMAT_SPEC.md` not `SPEC.md`

### Structure
- Start with # Title (H1)
- Use clear section headers (## H2)
- Include code examples where appropriate
- Add navigation links at top for long docs

### Content
- Be concise but complete
- Include examples
- Link to related documentation
- Keep up to date with code changes

---

## 🤝 Contributing to Docs

Found an issue or want to improve documentation?

1. Edit the relevant file
2. Follow the documentation standards above
3. Test any code examples
4. Submit a pull request

All documentation contributions are welcome! 🎉

---

## 📚 External Resources

- **Omakub (upstream)**: https://github.com/basecamp/omakub
- **Ubuntu 24.04 Docs**: https://help.ubuntu.com/
- **Docker Docs**: https://docs.docker.com/
- **GNOME Docs**: https://help.gnome.org/

---

## 🔍 Search Tips

Use your text editor or IDE to search across all documentation:

```bash
# Find documentation about a feature
grep -r "preflight" docs/

# Find all mentions of extensions
grep -r "extension" docs/

# Find troubleshooting info
grep -r "error\|issue\|problem" docs/
```

---

## 📊 Documentation Stats

- **Total Docs**: 20+ files
- **Total Words**: ~35,000+
- **Categories**: 5 (architecture, development, extensions, features, troubleshooting)
- **Last Updated**: November 2025

---

## 💬 Need Help?

- **GitHub Issues**: https://github.com/languageseed/bentobox/issues
- **Discussions**: https://github.com/languageseed/bentobox/discussions
- **Original Omakub**: https://omakub.org

---

**Happy building with Bentobox!** 🚀

