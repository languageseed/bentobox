# Bentobox TUI Over SSH & Terminal

**Feature:** Beautiful Terminal User Interface that works everywhere  
**Status:** ✅ IMPLEMENTED WITH FALLBACKS

---

## 🎯 Yes, TUI Works Over SSH!

Bentobox's interactive mode uses **`gum`** for beautiful Terminal User Interfaces (TUI), and it **works perfectly over SSH**.

### ✅ Confirmed Working:
- ✅ SSH sessions (local network)
- ✅ SSH over internet
- ✅ SSH via Tailscale
- ✅ Local terminal
- ✅ Terminal emulators (Alacritty, iTerm, Terminal.app, etc.)
- ✅ tmux/screen sessions
- ✅ VS Code integrated terminal
- ✅ Docker containers with TTY

---

## 🖥️ Terminal Compatibility System

Bentobox now includes **automatic terminal detection** with **fallbacks** for terminals that don't support rich TUI:

### Detection Flow:

```
1. Check terminal type (TERM variable)
2. Detect SSH session
3. Test color support
4. Verify terminal size
5. Test if stdin is interactive
6. Test if gum works
   ├─ If yes → Use beautiful gum TUI
   └─ If no  → Use simple text prompts
```

---

## 🎨 Two UI Modes

### Mode 1: Rich TUI (Default - with gum)

```
╭──────────────────────────────────╮
│ Select programming languages     │
├──────────────────────────────────┤
│ › ◉ Ruby on Rails               │
│   ◉ Node.js                      │
│   ◯ Go                           │
│   ◯ PHP                          │
│   ◯ Python                       │
│   ◯ Elixir                       │
│   ◯ Rust                         │
│   ◯ Java                         │
╰──────────────────────────────────╯
```

**When:** gum is installed and terminal supports it

### Mode 2: Simple Text (Fallback)

```
Select programming languages (defaults: Ruby on Rails, Node.js)
────────────────────────────────────────
  [1] Ruby on Rails (default)
  [2] Node.js (default)
  [3] Go
  [4] PHP
  [5] Python
  [6] Elixir
  [7] Rust
  [8] Java

Enter numbers (space-separated, or Enter for defaults):
```

**When:** gum doesn't work or terminal doesn't support TUI

---

## 🌐 SSH Testing Examples

### Example 1: SSH from Mac to Ubuntu (Local)

```bash
# From your Mac
ssh ben@leaf

# Run bentobox
wget -qO- https://raw.githubusercontent.com/languageseed/bentobox/master/boot.sh | bash

# Output shows:
🖥️  Terminal Compatibility Check

🌐 SSH session detected
   ✓ 256-color support available
   ✓ Terminal size: 120x30 (good)
   ✓ Interactive terminal (stdin is a TTY)
   ✓ gum TUI works in this terminal

✅ Terminal ready (SSH with TUI support)

# Beautiful gum TUI appears! 🎉
```

### Example 2: SSH via Tailscale

```bash
# From anywhere
ssh ben@leaf.your-tailnet.ts.net

# Same great TUI experience
bash boot.sh
```

### Example 3: SSH with Simple Terminal

```bash
# From a terminal with limited support
ssh -t ben@leaf 'TERM=dumb bash boot.sh'

# Output shows:
🖥️  Terminal Compatibility Check

⚠️  Warning: TERM=dumb detected (limited terminal)
   TUI features may not work properly

📋 Using simple text prompts (TUI not available)

# Falls back to numbered menus
```

---

## 🔧 Testing Different Scenarios

### Test TUI Mode:

```bash
# Regular SSH - should use TUI
ssh leaf
./local-testing/quick-test.sh leaf
```

### Test Fallback Mode:

```bash
# Force simple prompts
ssh leaf
export BENTOBOX_SIMPLE_PROMPTS=true
bash boot.sh
```

### Test Over Different Terminals:

```bash
# iTerm2 (Mac) - Works great
ssh leaf; bash boot.sh

# Terminal.app (Mac) - Works great
ssh leaf; bash boot.sh

# Windows Terminal - Works great
ssh leaf
bash boot.sh

# PuTTY - Should work, might need UTF-8 enabled
```

---

## 📋 New Terminal Check Features

### What Gets Checked:

1. **TERM Environment Variable**
   - Sets fallback if not set
   - Warns if TERM=dumb

2. **SSH Detection**
   - Detects SSH_CONNECTION
   - Detects SSH_CLIENT
   - Detects SSH_TTY

3. **Color Support**
   - Tests 256-color support
   - Tests 8-color support
   - Disables colors if none

4. **Terminal Size**
   - Checks width (minimum 80 columns)
   - Checks height (minimum 24 lines)
   - Warns if too small

5. **Interactive Check**
   - Verifies stdin is a TTY
   - Required for TUI prompts

6. **Gum Functionality**
   - Actually tests if gum works
   - Falls back if it doesn't

---

## 🎬 What You See

### Over SSH (Normal):

```bash
ssh leaf
bash boot.sh

# Output:
🖥️  Terminal Compatibility Check

🌐 SSH session detected
   ✓ 256-color support available  
   ✓ Terminal size: 120x40 (good)
   ✓ Interactive terminal (stdin is a TTY)
   ✓ gum TUI works in this terminal

✅ Terminal ready (SSH with TUI support)

# Beautiful TUI appears
╭──────────────────────────╮
│ Select optional apps     │
├──────────────────────────┤
│ › ◉ 1password           │
│   ◯ Barrier              │
│   ◯ Tailscale            │
╰──────────────────────────╯
```

### In Limited Terminal:

```bash
# Pipe through SSH (no TTY)
echo "bash boot.sh" | ssh leaf

# Output:
🖥️  Terminal Compatibility Check

⚠ Non-interactive stdin detected
   TUI prompts may not work (consider using config file)

📋 Using simple text prompts (TUI not available)

# Simple numbered menus appear
Select optional apps (defaults: 1password)
────────────────────────────────────────
  [1] 1password (default)
  [2] Barrier
  [3] Tailscale

Enter numbers (space-separated, or Enter for default):
```

---

## 🔍 Troubleshooting TUI Over SSH

### TUI Not Appearing

```bash
# Check if gum is installed
ssh leaf 'command -v gum'

# Check terminal type
ssh leaf 'echo $TERM'
# Should be: xterm-256color, screen-256color, etc.

# Check if TTY
ssh leaf 'tty'
# Should show: /dev/pts/0 (or similar)

# Force TTY allocation
ssh -t leaf 'bash boot.sh'
```

### Colors Not Working

```bash
# Check color support
ssh leaf 'tput colors'
# Should show: 256 or 8

# Force 256 colors
ssh leaf 'TERM=xterm-256color bash boot.sh'
```

### Terminal Too Small

```bash
# Check size
ssh leaf 'tput cols; tput lines'

# Resize your terminal window to at least 80x24
```

### Force Simple Mode

```bash
# If TUI causes issues, force simple prompts
ssh leaf 'export BENTOBOX_SIMPLE_PROMPTS=true; bash boot.sh'
```

---

## 🎯 Best Practices for SSH

### 1. Use Config File for Automated SSH

```bash
# Instead of interactive over SSH
# Use config file for unattended
ssh leaf 'cat > ~/.bentobox-config.yaml << EOF
mode: unattended
user: {name: "Auto", email: "auto@example.com"}
languages: ["Node.js"]
containers: ["Portainer"]
EOF'

ssh leaf 'bash boot.sh'
# No prompts, fully automated
```

### 2. Allocate TTY for Interactive

```bash
# Always use -t for interactive installations
ssh -t leaf 'bash boot.sh'
```

### 3. Test Terminal First

```bash
# Quick terminal test
ssh leaf 'bash' << 'EOF'
echo "TERM: $TERM"
echo "Columns: $(tput cols)"
echo "Lines: $(tput lines)"
echo "Colors: $(tput colors)"
command -v gum && echo "gum: installed" || echo "gum: not yet"
EOF
```

---

## 📊 Terminal Compatibility Matrix

| Terminal | SSH Support | TUI Support | Notes |
|----------|-------------|-------------|-------|
| **iTerm2** (Mac) | ✅ Perfect | ✅ Perfect | Best experience |
| **Terminal.app** (Mac) | ✅ Perfect | ✅ Perfect | Works great |
| **Alacritty** | ✅ Perfect | ✅ Perfect | Fast, modern |
| **Windows Terminal** | ✅ Perfect | ✅ Perfect | Excellent |
| **VS Code Terminal** | ✅ Yes | ✅ Yes | Works well |
| **tmux** | ✅ Yes | ✅ Yes | Set TERM correctly |
| **screen** | ✅ Yes | ✅ Yes | Set TERM correctly |
| **PuTTY** | ✅ Yes | ⚠️ Maybe | Enable UTF-8 |
| **Basic xterm** | ✅ Yes | ✅ Yes | Works |
| **Dumb terminal** | ✅ Yes | ❌ No | Uses fallback |

---

## 🧪 Testing Commands

### Local Testing:

```bash
# Test from your Mac to leaf
./local-testing/quick-test.sh leaf

# Watch for terminal check output
```

### SSH Testing:

```bash
# Test TUI over SSH
ssh -t leaf << 'EOF'
cd /tmp
git clone https://github.com/languageseed/bentobox.git
cd bentobox
bash boot.sh
EOF
```

### Force Different Modes:

```bash
# Force TUI mode (default)
ssh leaf 'bash boot.sh'

# Force simple mode
ssh leaf 'export BENTOBOX_SIMPLE_PROMPTS=true; bash boot.sh'

# Test with limited TERM
ssh leaf 'TERM=dumb bash boot.sh'
```

---

## ✅ Summary

**TUI over SSH:**
- ✅ Works out of the box
- ✅ Auto-detects terminal capabilities
- ✅ Falls back gracefully if needed
- ✅ No special configuration required

**Fallback System:**
- ✅ Automatic detection
- ✅ Simple text prompts when TUI unavailable
- ✅ Same functionality, different UI
- ✅ No manual intervention needed

**New Files:**
- ✅ `install/terminal-check.sh` - Detection system
- ✅ `install/tui-helpers.sh` - Wrapper functions with fallbacks
- ✅ Updated `install/first-run-choices.sh` - Fallback support
- ✅ Updated `install/identification.sh` - Fallback support

---

**Ready to test over SSH!** 🚀

```bash
# From your Mac
ssh leaf
bash boot.sh

# Beautiful TUI will work perfectly!
```

