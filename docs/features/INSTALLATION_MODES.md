# Bentobox Installation Modes

Bentobox supports **three installation modes** to accommodate different use cases:

1. **Interactive Mode** (default) - Human-guided with visual prompts
2. **Unattended Mode** - Fully automated with config file
3. **AI Mode** - Optimized for AI assistants and automation

---

## 🎯 Installation Modes

### Interactive Mode (Default)

**Who:** Human users installing locally  
**How:** Run boot.sh normally - you'll be prompted for choices

```bash
wget -qO- https://raw.githubusercontent.com/languageseed/bentobox/master/boot.sh | bash
```

**Features:**
- ✅ Beautiful `gum` TUI prompts
- ✅ Visual selection menus
- ✅ Real-time feedback
- ✅ Confirmation dialogs
- ✅ Best for first-time users

---

### Unattended Mode

**Who:** Automated deployments, scripts, CI/CD pipelines  
**How:** Create config file before running installation

```bash
# 1. Download config template
wget -O ~/.bentobox-config.yaml https://raw.githubusercontent.com/languageseed/bentobox/master/bentobox-config.yaml

# 2. Edit with your preferences
nano ~/.bentobox-config.yaml

# 3. Run installation (automatically detects config)
wget -qO- https://raw.githubusercontent.com/languageseed/bentobox/master/boot.sh | bash
```

**Features:**
- ✅ Zero human interaction required
- ✅ Reproducible installations
- ✅ Config file version control
- ✅ Perfect for fleet deployments
- ✅ CI/CD friendly

---

### AI Mode

**Who:** AI assistants (Claude, ChatGPT, etc.) setting up systems  
**How:** AI creates config with `mode: ai` setting

```bash
# AI creates this config programmatically
cat > ~/.bentobox-config.yaml << 'EOF'
mode: ai
user:
  name: "Auto Deploy"
  email: "deploy@example.com"
languages:
  - "Python"
  - "Node.js"
containers:
  - Portainer
  - OpenWebUI
ai:
  purpose: "AI development environment"
  report_installed: true
EOF

# Then runs installation
wget -qO- https://raw.githubusercontent.com/languageseed/bentobox/master/boot.sh | bash
```

**Features:**
- ✅ All unattended mode features
- ✅ Verbose output for AI parsing
- ✅ Installation report generation
- ✅ Error handling optimized for AI
- ✅ Substitution tolerance

---

## 📋 Configuration File

### Location Priority

Bentobox looks for config files in this order:

1. `$BENTOBOX_CONFIG` (environment variable)
2. `~/.bentobox-config.yaml`
3. `~/.bentobox-config.yml`
4. `$OMAKUB_PATH/bentobox-config.yaml`

If no config found → **Interactive Mode**

### Full Configuration Example

```yaml
---
mode: unattended  # or: interactive, ai

user:
  name: "John Developer"
  email: "john@example.com"

desktop:
  optional_apps:
    - 1password
    - Tailscale
    - Barrier
  web_apps:
    - "Chat GPT"

languages:
  - "Node.js"
  - "Python"

containers:
  - Portainer
  - OpenWebUI

theme: tokyo-night

settings:
  auto_reboot: false
  skip_confirmations: true
  verbose: false
  wallpaper: "pexels-pok-rie-33563-2049422.jpg"
```

See `bentobox-config.yaml` for complete template with all options.

---

## 🚀 Usage Examples

### Example 1: Personal Dev Machine (Interactive)

```bash
# Just run - you'll be prompted
wget -qO- https://raw.githubusercontent.com/languageseed/bentobox/master/boot.sh | bash
```

### Example 2: Team Standard Setup (Unattended)

```bash
# Download team's config from git
git clone https://github.com/yourteam/bentobox-configs.git
cp bentobox-configs/fullstack-dev.yaml ~/.bentobox-config.yaml

# Install with team standards
wget -qO- https://raw.githubusercontent.com/languageseed/bentobox/master/boot.sh | bash
```

### Example 3: CI/CD Test Environment (Unattended)

```yaml
# ci-test-config.yaml
mode: unattended
user:
  name: "CI Bot"
  email: "ci@company.com"
languages:
  - "Node.js"
containers:
  - Portainer
settings:
  auto_reboot: false
  skip_confirmations: true
```

```bash
# In CI pipeline
export BENTOBOX_CONFIG=./ci-test-config.yaml
wget -qO- https://raw.githubusercontent.com/languageseed/bentobox/master/boot.sh | bash
```

### Example 4: AI Assistant Setup (AI Mode)

```python
# AI creates config programmatically
config = {
    "mode": "ai",
    "user": {
        "name": "AI Assistant",
        "email": "ai@example.com"
    },
    "languages": ["Python", "Node.js"],
    "containers": ["Portainer", "OpenWebUI", "Ollama"],
    "ai": {
        "purpose": "ML development environment",
        "report_installed": True
    }
}

# AI writes config and runs install
import yaml
with open('/tmp/bentobox-config.yaml', 'w') as f:
    yaml.dump(config, f)

os.environ['BENTOBOX_CONFIG'] = '/tmp/bentobox-config.yaml'
os.system('wget -qO- https://raw.githubusercontent.com/languageseed/bentobox/master/boot.sh | bash')
```

---

## 🔧 Available Options

### Optional Desktop Apps

- `1password` - Password manager
- `Barrier` - KVM sharing (keyboard/mouse)
- `Tailscale` - VPN for remote access
- `WinBoat` - Run Windows apps on Linux
- `Sublime-Text` - Code editor
- `Windows-ISO` - Pre-download Windows 10 ISO

### Web Apps (PWAs)

- `"Chat GPT"` - ChatGPT web app
- `"Google Photos"` - Google Photos
- `"Google Contacts"` - Google Contacts  
- `"Tailscale"` - Tailscale admin panel

### Programming Languages

- `"Ruby on Rails"`
- `"Node.js"`
- `"Go"`
- `"PHP"`
- `"Python"`
- `"Elixir"`
- `"Rust"`
- `"Java"`

### Docker Containers

- `Portainer` - Docker web UI (recommended)
- `OpenWebUI` - AI chat interface
- `Ollama` - Local LLM server

### Themes

- `tokyo-night` (default)
- `nord`
- `catppuccin`
- `gruvbox`
- `everforest`
- `kanagawa`
- `rose-pine`
- `osaka-jade`
- `ristretto`
- `matte-black`

---

## 📊 Mode Comparison

| Feature | Interactive | Unattended | AI Mode |
|---------|------------|------------|---------|
| **Prompts User** | ✅ Yes | ❌ No | ❌ No |
| **Config Required** | ❌ No | ✅ Yes | ✅ Yes |
| **Auto-Reboot** | User choice | Optional | Optional |
| **Verbose Output** | Normal | Configurable | Always |
| **Error Messages** | Human-friendly | Standard | AI-friendly |
| **Installation Report** | ❌ No | ❌ No | ✅ Yes |
| **Reproducible** | ❌ No | ✅ Yes | ✅ Yes |
| **Version Control** | ❌ No | ✅ Yes | ✅ Yes |

---

## 🧪 Testing Both Modes

### Test Interactive Mode

```bash
# Make sure no config file exists
rm -f ~/.bentobox-config.yaml

# Run installation - will prompt
bash boot.sh
```

### Test Unattended Mode

```bash
# Create minimal config
cat > ~/.bentobox-config.yaml << 'EOF'
mode: unattended
user:
  name: "Test User"
  email: "test@example.com"
languages:
  - "Node.js"
containers:
  - Portainer
EOF

# Run installation - no prompts
bash boot.sh
```

---

## 🎯 Configuration Presets

### Minimal Developer

```yaml
mode: unattended
user:
  name: "Developer"
  email: "dev@example.com"
desktop:
  optional_apps: []
languages:
  - "Node.js"
containers:
  - Portainer
```

### Full Stack Developer

```yaml
mode: unattended
user:
  name: "Full Stack Developer"
  email: "fullstack@example.com"
desktop:
  optional_apps:
    - 1password
    - Tailscale
languages:
  - "Node.js"
  - "Python"
  - "Go"
containers:
  - Portainer
  - OpenWebUI
  - Ollama
```

### AI/ML Developer

```yaml
mode: ai
user:
  name: "ML Engineer"
  email: "ml@example.com"
desktop:
  optional_apps:
    - Tailscale
languages:
  - "Python"
containers:
  - Portainer
  - OpenWebUI
  - Ollama
ai:
  purpose: "Machine learning development"
  report_installed: true
```

### Windows App Developer

```yaml
mode: unattended
user:
  name: "Windows Dev"
  email: "windev@example.com"
desktop:
  optional_apps:
    - WinBoat
    - Windows-ISO
    - Tailscale
languages:
  - "Node.js"
  - "Python"
containers:
  - Portainer
```

---

## 🔍 Troubleshooting

### Config Not Being Used

```bash
# Check if config file exists and is readable
ls -la ~/.bentobox-config.yaml
cat ~/.bentobox-config.yaml

# Check config syntax (must be valid YAML)
# If you have yq installed:
yq eval ~/.bentobox-config.yaml

# Force specific config file
export BENTOBOX_CONFIG=/path/to/config.yaml
bash boot.sh
```

### Installation Still Prompts in Unattended Mode

```bash
# Make sure mode is set correctly
grep "^mode:" ~/.bentobox-config.yaml

# Should output: mode: unattended
# or: mode: ai
```

### Debugging Config Parsing

```bash
# Add verbose mode to config
echo "settings:" >> ~/.bentobox-config.yaml
echo "  verbose: true" >> ~/.bentobox-config.yaml

# Run installation - will show what config was loaded
bash boot.sh
```

---

## 🎓 Best Practices

### 1. Version Control Your Configs

```bash
# Store team configs in git
git-repo/
├── configs/
│   ├── minimal.yaml
│   ├── fullstack.yaml
│   ├── ai-dev.yaml
│   └── windows-dev.yaml
└── README.md
```

### 2. Template Configs for Team

```yaml
# team-standard.yaml
mode: unattended
user:
  name: "REPLACE_WITH_YOUR_NAME"
  email: "REPLACE_WITH_YOUR_EMAIL"
# ... rest of standardized team config
```

### 3. Environment-Specific Configs

```bash
# Production
export BENTOBOX_CONFIG=./configs/production.yaml

# Development
export BENTOBOX_CONFIG=./configs/development.yaml

# Testing
export BENTOBOX_CONFIG=./configs/testing.yaml
```

### 4. Validate Before Deploy

```bash
# Check config syntax
if yq eval ~/.bentobox-config.yaml > /dev/null 2>&1; then
    echo "✅ Config valid"
else
    echo "❌ Config invalid"
fi
```

---

## 📚 Additional Resources

- **Config Template:** `bentobox-config.yaml`
- **Config Parser:** `install/config-loader.sh`
- **Installation Script:** `install.sh`
- **Interactive Choices:** `install/first-run-choices.sh`

---

## ✅ Quick Reference

```bash
# Interactive (default)
bash boot.sh

# Unattended (with config in default location)
bash boot.sh  # automatically detects ~/.bentobox-config.yaml

# Unattended (with custom config)
export BENTOBOX_CONFIG=/path/to/config.yaml
bash boot.sh

# AI Mode (set in config file)
# mode: ai in config, then bash boot.sh
```

---

**Ready to automate your bentobox deployments!** 🚀

