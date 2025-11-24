# Bentobox Pre-flight Check System

**Feature:** System readiness validation before installation  
**Status:** ✅ IMPLEMENTED

---

## 🎯 Purpose

The pre-flight check system scans your system **before installation** to:

1. ✅ **Verify system requirements** (Ubuntu version, disk space, RAM)
2. ✅ **Check APT state** (cache age, pending updates, broken packages)
3. ✅ **Detect conflicting packages** (Docker from different sources, etc.)
4. ✅ **Identify already-installed components** (avoid reinstalling)
5. ✅ **Test connectivity** (internet, GitHub)
6. ✅ **Check virtualization** (for WinBoat support)

---

## 🚀 How It Works

### Automatic Integration

The pre-flight check runs **automatically** at the start of every installation:

```bash
bash boot.sh

# Output:
# 🔍 Bentobox Pre-flight Check
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 
# 📋 System Readiness
# ─────────────────────────────────────────
#   ✓ Ubuntu 24.04 detected
#   ✓ Running as regular user
#   ✓ Sudo access available
#   ✓ Disk space: 45GB available (good)
#   ✓ RAM: 16GB (good)
#   ✓ Internet connection active
#   ✓ GitHub accessible
# 
# 📦 APT Package System
# ─────────────────────────────────────────
#   ⚠ APT cache is 8 days old (will run apt update)
#   ⚠ 42 packages have updates available
#   ✓ No broken packages
# ...
```

---

## 📊 What Gets Checked

### 1. System Readiness
- ✅ Ubuntu version (24.04+ required)
- ✅ User account (not root)
- ✅ Sudo access
- ✅ Disk space (15GB+ required, 30GB+ recommended)
- ✅ RAM (4GB+ required, 8GB+ recommended)
- ✅ Internet connectivity
- ✅ GitHub accessibility

### 2. APT Package System
- ✅ APT lock status
- ✅ Cache age (warns if >7 days old)
- ✅ Pending updates count
- ✅ Broken packages

### 3. Conflicting Packages
- ⚠️ docker.io (Ubuntu package) vs docker-ce (bentobox preference)
- ⚠️ Snap Docker
- ⚠️ Node.js/nvm (bentobox uses mise)
- ⚠️ rbenv/RVM (bentobox uses mise)
- ⚠️ pyenv (bentobox uses mise)
- ⚠️ Existing Alacritty
- ⚠️ Existing VS Code

### 4. Already Installed Components
- ℹ️ Previous bentobox installation
- ℹ️ Docker (with version)
- ℹ️ Running containers (Portainer, OpenWebUI, Ollama)
- ℹ️ Development tools (mise, gh, lazygit)

### 5. Desktop Environment
- ✅ GNOME detection (for desktop apps)
- ⚠️ Other desktops (terminal-only install)
- ℹ️ No desktop (server mode)

### 6. Virtualization Support
- ✅ CPU virtualization (vmx/svm)
- ✅ KVM device (/dev/kvm)
- ⚠️ No virtualization (WinBoat won't work)

---

## 🎨 Output Symbols

```
✓  - Success (green)
⚠  - Warning (yellow)
✗  - Error (red)
ℹ  - Information (blue)
```

---

## 🔧 Configuration

### Skip Pre-flight Check

```yaml
# bentobox-config.yaml
settings:
  skip_preflight: true  # Skip all checks
```

Or via environment variable:

```bash
export BENTOBOX_SKIP_PREFLIGHT=true
bash boot.sh
```

### Stop on Warnings

```yaml
# bentobox-config.yaml
settings:
  stop_on_warnings: true  # Don't proceed if warnings found
```

### Auto-upgrade Packages

```yaml
# bentobox-config.yaml
settings:
  auto_upgrade: true  # Automatically run apt upgrade
```

---

## 🎬 Behavior by Mode

### Interactive Mode

**Errors found:**
- ❌ Installation aborts
- Shows what needs to be fixed

**Warnings found:**
- ⚠️ Shows warnings
- Asks: "Continue anyway?"
- User decides

**No issues:**
- ✅ Proceeds automatically

### Unattended Mode

**Errors found:**
- ❌ Installation aborts
- Exit code 1

**Warnings found:**
- ⚠️ Proceeds by default
- Unless `stop_on_warnings: true`

**No issues:**
- ✅ Proceeds automatically

### AI Mode

**All issues:**
- Verbose output for AI parsing
- Reports findings in detail
- AI can decide how to proceed

---

## 📋 APT Maintenance

After pre-flight check, APT maintenance runs if needed:

### APT Update

Runs automatically if:
- Cache is >7 days old
- No cache exists
- Force update requested

```bash
# Forced update
export BENTOBOX_NEEDS_APT_UPDATE=true
```

### APT Upgrade

**Interactive Mode:**
- Asks user if they want to upgrade
- Shows package count
- User decides

**Unattended Mode:**
- Only if `auto_upgrade: true` in config
- Otherwise skips with message

```yaml
settings:
  auto_upgrade: true  # Auto-upgrade in unattended mode
```

---

## 🧪 Testing Examples

### Example 1: Fresh Ubuntu (Good)

```
🔍 Bentobox Pre-flight Check

📋 System Readiness
  ✓ Ubuntu 24.04 detected
  ✓ Running as regular user
  ✓ Sudo access available
  ✓ Disk space: 50GB available (good)
  ✓ RAM: 16GB (good)
  ✓ Internet connection active
  ✓ GitHub accessible

📦 APT Package System
  ✓ APT is not locked
  ✓ APT cache is fresh
  ⚠ 120 packages have updates available
  ✓ No broken packages

⚠️  Conflicting Packages
  ✓ No conflicting packages detected

📦 Already Installed Components
  ✓ No previous installation detected

✅ Pre-flight check complete
```

### Example 2: System with Conflicts

```
🔍 Bentobox Pre-flight Check

⚠️  Conflicting Packages
  ⚠ docker.io package installed (bentobox installs docker-ce)
     Consider: sudo apt remove docker.io
  ⚠ Node.js already installed: /usr/bin/node
     Bentobox uses mise for language management
  ⚠ RVM installed (bentobox uses mise for Ruby)

💡 Recommendations
  • Review conflicting packages above
  • Consider removing conflicts before installation

⚠️  Warnings detected. Continue anyway?
```

### Example 3: Critical Issues

```
🔍 Bentobox Pre-flight Check

📋 System Readiness
  ✗ Ubuntu 20.04 - Bentobox requires 24.04+
  ✗ Disk space: 8GB available (need 15GB+)
  ✗ No internet connection

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✗ 3 critical issue(s) found

❌ Cannot proceed with installation due to critical issues
```

---

## 🔍 Troubleshooting

### "APT is locked"

```bash
# Wait for other package managers to finish
# Or kill if stuck:
sudo killall apt apt-get dpkg
sudo dpkg --configure -a
```

### "Broken packages detected"

```bash
# Fix broken packages first
sudo dpkg --configure -a
sudo apt --fix-broken install
```

### "No internet connection"

```bash
# Check network
ping -c 3 8.8.8.8

# Check DNS
ping -c 3 github.com

# If DNS fails, try different DNS:
echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf
```

### Skip Checks for Testing

```bash
# Skip pre-flight entirely
export BENTOBOX_SKIP_PREFLIGHT=true
bash boot.sh
```

---

## 🎯 Benefits

### Before Pre-flight Check:
- ❌ Install fails midway due to conflicts
- ❌ Wastes time on broken systems
- ❌ No idea why it failed
- ❌ Hard to troubleshoot

### After Pre-flight Check:
- ✅ Issues caught before installation starts
- ✅ Clear error messages
- ✅ Recommendations for fixes
- ✅ Better user experience
- ✅ Fewer support requests

---

## 📊 Exit Codes

```bash
0  - No issues, safe to proceed
1  - Critical errors, cannot proceed
2  - Warnings found, user should decide
```

---

## 🔧 Advanced Usage

### Run Pre-flight Standalone

```bash
# Just check, don't install
bash install/preflight-check.sh

# Check exit code
echo $?
# 0 = good, 1 = errors, 2 = warnings
```

### Custom Checks in Scripts

```bash
# In your automation scripts
source install/preflight-check.sh

if [ $? -eq 0 ]; then
    echo "System ready!"
else
    echo "System not ready"
    exit 1
fi
```

### CI/CD Integration

```yaml
# .github/workflows/test.yml
- name: Pre-flight Check
  run: |
    bash install/preflight-check.sh
    if [ $? -gt 0 ]; then
      echo "Pre-flight failed"
      exit 1
    fi
```

---

## 📝 Adding Custom Checks

Edit `install/preflight-check.sh` to add your own checks:

```bash
# Custom check example
echo "🔧 Custom Checks"
echo "─────────────────────────────────────────"

# Check for specific software
if command -v myapp &> /dev/null; then
    echo -e "  ${YELLOW}⚠${NC} myapp already installed"
    WARNINGS=$((WARNINGS + 1))
else
    echo -e "  ${GREEN}✓${NC} myapp not found (good)"
fi
```

---

## 🎓 Best Practices

### 1. Run on Fresh Systems First
```bash
# Test on clean Ubuntu 24.04 VM
bash boot.sh
# → Should pass all checks
```

### 2. Document Known Conflicts
```bash
# If your team uses specific tools, document them
# Example: "We use nvm, expect Node.js warning"
```

### 3. Use in CI/CD
```bash
# Pre-flight check in automated testing
# Catches environment issues early
```

### 4. Review Warnings
```bash
# Don't ignore warnings
# They indicate potential issues
```

---

## ✅ Summary

The pre-flight check system:

- ✅ Runs automatically before installation
- ✅ Catches issues early
- ✅ Provides clear error messages
- ✅ Suggests fixes for common problems
- ✅ Works in all three modes (interactive/unattended/AI)
- ✅ Configurable (can skip or customize)
- ✅ Handles APT maintenance
- ✅ Prevents wasted time on broken systems

---

**Your installation is now safer and more reliable!** 🎉

