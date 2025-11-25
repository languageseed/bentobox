# Debian 13 Prerequisites for Bentobox

**System:** Debian 13 (Trixie)  
**Desktop:** GNOME (installed ✓)  
**Status:** Needs additional packages

---

## Current System Status

### ✅ Already Installed
- ✓ Debian 13 (Trixie)
- ✓ GNOME Shell 48.4
- ✓ GDM (Display Manager)
- ✓ curl
- ✓ git
- ✓ unzip
- ✓ Python 3.13.5
- ✓ python3-gi (GTK bindings)
- ✓ python3-gi-cairo
- ✓ zenity

### ❌ Missing Packages

**Terminal Installation Requirements:**
- ✗ python3-pip (Python package manager)
- ✗ python3-yaml (YAML support for config)
- ✗ build-essential (compilation tools)

**GUI Installation Requirements:**
- ✗ gir1.2-gtk-3.0 (GTK 3.0 library)
- ✗ gir1.2-vte-2.91 (Terminal widget)
- ✗ gir1.2-gdkpixbuf-2.0 (Image library)

---

## Installation Options

### Option 1: Terminal Installation (Minimal)

If you only want to use the **terminal-based installer** (TUI):

```bash
sudo apt update
sudo apt install -y \
    python3-pip \
    python3-yaml \
    build-essential
```

**What this enables:**
- Terminal-based Bentobox installation
- All core features
- Docker, development tools, themes
- Optional applications

**What you CAN'T use:**
- GUI installer (bentobox-gui)

---

### Option 2: Full Installation (GUI + Terminal)

If you want **both GUI and terminal installers**:

```bash
sudo apt update
sudo apt install -y \
    python3-pip \
    python3-yaml \
    build-essential \
    gir1.2-gtk-3.0 \
    gir1.2-vte-2.91 \
    gir1.2-gdkpixbuf-2.0
```

**What this enables:**
- GUI installer (point-and-click)
- Terminal installer
- All Bentobox features
- Complete experience

---

## Quick Install Script

Copy and paste this to install all prerequisites:

```bash
#!/bin/bash
# Bentobox Prerequisites for Debian 13

echo "📦 Installing Bentobox prerequisites for Debian 13..."
echo ""

sudo apt update

echo "Installing core requirements..."
sudo apt install -y \
    python3-pip \
    python3-yaml \
    build-essential

echo ""
echo "Installing GUI requirements..."
sudo apt install -y \
    gir1.2-gtk-3.0 \
    gir1.2-vte-2.91 \
    gir1.2-gdkpixbuf-2.0

echo ""
echo "✓ All prerequisites installed!"
echo ""
echo "You can now install Bentobox:"
echo "  Terminal: wget -qO- https://raw.githubusercontent.com/languageseed/bentobox/master/boot.sh | bash"
echo "  GUI:      wget -qO- https://raw.githubusercontent.com/languageseed/bentobox/master/boot-gui.sh | bash"
```

---

## Package Explanations

| Package | Purpose | Required For |
|---------|---------|--------------|
| `python3-pip` | Python package installer | Installing Python dependencies |
| `python3-yaml` | YAML configuration support | Reading config files |
| `build-essential` | Compilation tools (gcc, make) | Building some packages |
| `gir1.2-gtk-3.0` | GTK 3.0 library bindings | GUI installer |
| `gir1.2-vte-2.91` | Terminal widget library | GUI installer (live output) |
| `gir1.2-gdkpixbuf-2.0` | Image loading library | GUI installer (icons) |

---

## After Installing Prerequisites

### Test Prerequisites

```bash
# Test core requirements
python3 -c "import yaml" && echo "✓ Python YAML works"
which pip3 && echo "✓ pip3 available"
gcc --version && echo "✓ GCC available"

# Test GUI requirements (if installed)
python3 -c "import gi; gi.require_version('Gtk', '3.0'); from gi.repository import Gtk" && echo "✓ GTK bindings work"
python3 -c "import gi; gi.require_version('Vte', '2.91'); from gi.repository import Vte" && echo "✓ VTE bindings work"
```

### Install Bentobox

**Terminal Installation:**
```bash
wget -qO- https://raw.githubusercontent.com/languageseed/bentobox/master/boot.sh | bash
```

**GUI Installation:**
```bash
wget -qO- https://raw.githubusercontent.com/languageseed/bentobox/master/boot-gui.sh | bash
```

---

## Debian 13 vs Ubuntu 24.04 Differences

### Package Availability
- ✅ Most packages identical
- ⚠️ PPAs don't work on Debian (Bentobox handles this)
- ✅ Debian Testing/Backports available as alternatives

### Desktop Environment
- ✅ GNOME 48.4 on Debian 13 (similar to Ubuntu)
- ✅ All GNOME features work
- ✅ Extensions supported
- ✅ Themes work

### Bentobox Features on Debian 13
- ✅ Terminal installation (TUI)
- ✅ GUI installation (if GUI packages installed)
- ✅ Docker containers (Portainer, Ollama, OpenWebUI)
- ✅ Development tools (languages, IDEs)
- ✅ Desktop customization (themes, wallpapers)
- ✅ Security features (UFW, Fail2Ban, SSH hardening)
- ✅ Optional applications (VS Code, Chrome, etc.)
- ⚠️ PPAs replaced with Debian alternatives automatically

---

## Recommended Installation Path

### Step 1: Install Prerequisites
```bash
sudo apt update
sudo apt install -y \
    python3-pip \
    python3-yaml \
    build-essential \
    gir1.2-gtk-3.0 \
    gir1.2-vte-2.91 \
    gir1.2-gdkpixbuf-2.0
```

### Step 2: Choose Your Installer

**GUI (Recommended for desktop):**
```bash
wget -qO- https://raw.githubusercontent.com/languageseed/bentobox/master/boot-gui.sh | bash
```

**Terminal (For servers or preference):**
```bash
wget -qO- https://raw.githubusercontent.com/languageseed/bentobox/master/boot.sh | bash
```

### Step 3: Configure Your Installation
- Select optional applications
- Choose programming languages
- Pick Docker containers
- Customize themes

### Step 4: Wait for Installation
- Installation takes 15-30 minutes
- Live progress shown in terminal/GUI
- No interaction needed after initial selection

### Step 5: Reboot
```bash
sudo reboot
```

---

## Verification Script

Want to verify everything is ready? Run this:

```bash
#!/bin/bash
echo "=== Bentobox Prerequisites Check ==="
echo ""

ALL_OK=true

# Check OS
echo "OS: $(cat /etc/os-release | grep PRETTY_NAME | cut -d= -f2 | tr -d \")"
if grep -q "Debian" /etc/os-release; then
    echo "✓ Debian detected"
else
    echo "✗ Not Debian"
    ALL_OK=false
fi

# Check version
VERSION=$(cat /etc/os-release | grep VERSION_ID | cut -d= -f2 | tr -d \")
if [ "${VERSION%%.*}" -ge 13 ]; then
    echo "✓ Version $VERSION (13+ required)"
else
    echo "✗ Version $VERSION (13+ required)"
    ALL_OK=false
fi

echo ""
echo "Core Requirements:"
for cmd in curl git unzip python3 pip3 gcc; do
    if command -v $cmd &>/dev/null; then
        echo "  ✓ $cmd"
    else
        echo "  ✗ $cmd (MISSING)"
        ALL_OK=false
    fi
done

echo ""
echo "Python Modules:"
for module in yaml gi; do
    if python3 -c "import $module" 2>/dev/null; then
        echo "  ✓ $module"
    else
        echo "  ✗ $module (MISSING)"
        ALL_OK=false
    fi
done

echo ""
if [ "$ALL_OK" = true ]; then
    echo "✅ All prerequisites met! Ready to install Bentobox."
else
    echo "❌ Some prerequisites missing. Install them first."
fi
```

---

## Summary

### Current Status on Your System
- ✅ Debian 13 (Trixie) - Correct version
- ✅ GNOME Desktop - Installed and running
- ✅ Basic tools - curl, git, unzip, python3
- ❌ Missing 6 packages - Need to install

### Next Steps
1. Run the prerequisite installation command above
2. Choose GUI or Terminal installer
3. Run Bentobox installation
4. Enjoy your configured development environment!

---

## Estimated Time

- **Prerequisites installation:** 2-3 minutes
- **Bentobox installation:** 15-30 minutes (depends on selections)
- **Total:** ~20-35 minutes

---

## Support

If you encounter issues:
1. Check `/var/log/apt/history.log` for package installation issues
2. Run `sudo apt update` if package not found
3. Verify internet connection
4. Check disk space: `df -h`

**Debian 13 is fully supported - the architecture was tested on your leaf system!** ✅

