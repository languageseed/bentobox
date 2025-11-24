# Bentobox vs Omakub: Architectural Comparison

## Executive Summary

**Omakub:** Pure bash orchestration with interactive prompts
**Bentobox:** Python orchestrator + bash workers + GTK GUI with state management

The Bentobox approach provides better error handling, state persistence, parallel execution, and a modern GUI while maintaining Omakub's modular bash scripts for actual installation tasks.

---

## Architecture Comparison

### Omakub Architecture

```
boot.sh (entry point)
    ↓
install.sh (bash orchestrator)
    ↓
├─ terminal.sh (sources all terminal/*.sh)
│   ├─ docker.sh
│   ├─ app-neovim.sh
│   ├─ mise.sh
│   └─ ... (sourced in sequence)
│
└─ desktop.sh (sources all desktop/*.sh)
    ├─ app-chrome.sh
    ├─ app-vscode.sh
    └─ ... (sourced in sequence)

Interactive prompts: gum choose/confirm
Error handling: set -e (exit on first error)
State: None (no persistence)
Recovery: Start over from scratch
```

**Characteristics:**
- ✅ Simple and straightforward
- ✅ Easy to understand for bash users
- ❌ No state persistence
- ❌ Exits on first error (`set -e`)
- ❌ Must restart from beginning on failure
- ❌ No parallel execution
- ❌ Scripts `source` each other (exit vs return issues)
- ❌ Hard to track what's installed
- ❌ Interactive-only (requires human)

---

### Bentobox Architecture

```
boot.sh (entry point - downloads from GitHub)
    ↓
install.sh (thin wrapper)
    ↓
orchestrator.py (Python brain) ←→ gui.py (GTK UI)
    ↓
├─ Load Config (YAML)
├─ Load State (JSON)
├─ Discover Components
├─ Run Preflight Check
├─ Build Installation Plan
└─ Execute Plan
    ↓
    ├─ subprocess.run(terminal/docker.sh)
    ├─ subprocess.run(terminal/app-neovim.sh)
    ├─ subprocess.run(desktop/app-chrome.sh)
    └─ ... (each as independent process)
    ↓
    Save State after each step
    ↓
Post-Install Tasks
    ↓
Complete
```

**Characteristics:**
- ✅ State persistence (JSON)
- ✅ Configuration-driven (YAML)
- ✅ Resume from failure point
- ✅ Parallel execution possible
- ✅ Scripts run as subprocesses (proper exit handling)
- ✅ Comprehensive error handling
- ✅ Progress tracking
- ✅ Both CLI and GUI interfaces
- ✅ Unattended/AI-driven installation
- ✅ Pre-flight checks with auto-adjustment
- ✅ Uninstall capability

---

## Key Differences

### 1. **Error Handling**

#### Omakub:
```bash
#!/bin/bash
set -e  # Exit on ANY error

# If this fails, entire script stops
sudo apt install some-package

# This never runs if above failed
echo "Installation complete"
```

**Problem:** One failure kills the entire installation. No recovery.

#### Bentobox:
```python
def run_script(self, script_path):
    """Execute bash script as subprocess"""
    try:
        result = subprocess.run(
            ['bash', str(script_path)],
            capture_output=True,
            timeout=600,
            check=False  # Don't raise on non-zero exit
        )
        
        # Update state
        if result.returncode == 0:
            self.state['completed'].append(script_name)
        else:
            self.state['failed'].append(script_name)
        
        # Continue to next component
        return result.returncode == 0
        
    except Exception as e:
        self.state['failed'].append(script_name)
        # Log error but continue
        return False
    finally:
        # Always save state
        self.save_state()
```

**Benefit:** Each component isolated. Failures logged but don't stop entire process. State persisted at every step.

---

### 2. **State Management**

#### Omakub:
```bash
# No state persistence
# If script fails halfway through:
# - No record of what was installed
# - Must start over from beginning
# - May try to reinstall things
# - No way to resume
```

#### Bentobox:
```json
// ~/.bentobox-state.json
{
  "installation_started": "2025-11-24T10:30:00",
  "completed": [
    "docker.sh",
    "app-neovim.sh",
    "app-chrome.sh"
  ],
  "failed": [
    "app-cursor.sh"  // Had an error
  ],
  "skipped": [
    "app-vscode.sh"  // User didn't select
  ],
  "last_update": "2025-11-24T10:45:00"
}
```

**Benefits:**
- ✅ Resume from where it failed
- ✅ Skip already-installed components
- ✅ Track what succeeded/failed
- ✅ Intelligent recovery
- ✅ Show progress in GUI

---

### 3. **Script Execution**

#### Omakub:
```bash
# install.sh
source terminal.sh

# terminal.sh
for script in terminal/*.sh; do
    source "$script"  # Runs in same shell
done

# Problem: If script does "exit 0" → entire process exits
# Must use "return 0" but that's weird for standalone scripts
```

**Issues:**
- Scripts share same shell environment
- `exit` vs `return` confusion
- Variables can leak between scripts
- Hard to isolate failures

#### Bentobox:
```python
# orchestrator.py
for script in installation_plan:
    # Each script runs as independent subprocess
    result = subprocess.run(['bash', script_path], ...)
    
    # Clean environment
    # Proper exit codes
    # Isolated failures
    # Can run in parallel (future)
```

**Benefits:**
- ✅ Clean subprocess for each script
- ✅ Proper exit code handling
- ✅ No environment pollution
- ✅ Can use `exit` normally in scripts
- ✅ Potential for parallel execution

---

### 4. **Configuration**

#### Omakub:
```bash
# All choices are interactive
gum choose "Cursor" "VS Code" "Both" "None"

# Can't automate
# Can't script
# Must be human-driven
```

#### Bentobox:
```yaml
# ~/.bentobox-config.yaml
mode: unattended  # or interactive or ai

desktop:
  optional_apps:
    - cursor
    - chrome
    - alacritty

languages:
  - nodejs
  - python

containers:
  - portainer
  - open-webui

settings:
  auto_reboot: false
  verbose: true
  stop_on_warnings: false
```

**Benefits:**
- ✅ Unattended installations
- ✅ AI can generate config
- ✅ CI/CD integration
- ✅ Version-controlled configs
- ✅ Multiple machine deployments
- ✅ Still supports interactive mode

---

### 5. **Pre-flight Checks**

#### Omakub:
```bash
# Minimal checks
# Just starts installing
# Discovers conflicts mid-installation
# May break partially-installed system
```

#### Bentobox:
```bash
# preflight-check.sh
✅ Check disk space (25GB+ required)
✅ Check RAM (4GB+ required)
✅ Check internet connectivity
✅ Check for conflicting packages
✅ Detect already-installed components
✅ Check virtualization support
✅ Scan for broken packages
✅ Warn about potential issues

# Auto-adjustment
export SKIP_DOCKER=1  # Already installed
export SKIP_NEOVIM=1  # Already present
```

**Benefits:**
- ✅ Catch problems before installation
- ✅ Avoid conflicts
- ✅ Skip already-installed components
- ✅ Intelligent about existing setup
- ✅ Clear warnings before proceeding

---

### 6. **User Interface**

#### Omakub:
```bash
# Terminal only
# gum prompts (TUI)
# Must be interactive
# No progress tracking
# No visual status

gum choose "Option 1" "Option 2"
```

#### Bentobox:
```python
# Multiple interfaces:

# 1. CLI (like Omakub)
bash install.sh

# 2. GUI (GTK desktop app)
bentobox-gui
# - Welcome tab with instructions
# - Component selection with checkboxes
# - Installation progress with progress bar
# - Status view showing completed/failed
# - Desktop customization tab
# - Uninstall button

# 3. Unattended (config-driven)
bash install.sh --unattended

# 4. AI-driven (same as unattended)
# AI generates config, then runs install
```

**Benefits:**
- ✅ Desktop users: beautiful GUI
- ✅ SSH users: CLI with TUI
- ✅ Servers: unattended mode
- ✅ AI agents: config + unattended
- ✅ Visual progress tracking
- ✅ Better user experience

---

### 7. **Component Discovery**

#### Omakub:
```bash
# Hardcoded in install.sh
source terminal.sh
source desktop.sh

# terminal.sh has hardcoded list
# desktop.sh has hardcoded list

# Adding new component:
# 1. Create script
# 2. Modify terminal.sh or desktop.sh
# 3. Update documentation
```

#### Bentobox:
```python
def discover_components(self):
    """Auto-discover installation components"""
    
    # Scan directories
    terminal_scripts = list((self.omakub_path / 'install/terminal').glob('*.sh'))
    desktop_scripts = list((self.omakub_path / 'install/desktop').glob('*.sh'))
    
    # Exclude orchestrator scripts
    exclude = ['terminal.sh', 'desktop.sh', 'preflight-check.sh']
    
    # Auto-register all found scripts
    for script in terminal_scripts:
        if script.name not in exclude:
            self.components['terminal'].append(script)
    
    # No hardcoding needed!
```

**Benefits:**
- ✅ Drop in new script → auto-discovered
- ✅ No manual registration
- ✅ Dynamic component list
- ✅ Easier to extend
- ✅ Less maintenance

---

### 8. **Debugging & Logging**

#### Omakub:
```bash
# Output goes to terminal
# No log files
# Hard to debug after the fact
# Lost if terminal closes

echo "Installing package..."
sudo apt install package
```

#### Bentobox:
```python
# Capture all output
result = subprocess.run(
    ['bash', script_path],
    capture_output=True,  # Capture stdout/stderr
    text=True
)

# Log to file
with open(log_file, 'a') as f:
    f.write(f"[{timestamp}] Running {script_name}\n")
    f.write(f"stdout: {result.stdout}\n")
    f.write(f"stderr: {result.stderr}\n")
    f.write(f"exit code: {result.returncode}\n")

# Show in GUI
GLib.idle_add(self.append_output, result.stdout)

# Save to state
self.state['logs'].append({
    'script': script_name,
    'exit_code': result.returncode,
    'timestamp': timestamp
})
```

**Benefits:**
- ✅ Full output captured
- ✅ Persistent logs
- ✅ Debug failures later
- ✅ Show in GUI and CLI
- ✅ State file has history

---

### 9. **Recovery & Uninstall**

#### Omakub:
```bash
# No uninstall
# No recovery mechanism
# Manual cleanup required
# Hope you remember what was installed

# To remove:
# - Figure out what was installed
# - Manually apt remove each package
# - Clean up configs by hand
# - Reset settings manually
```

#### Bentobox:
```python
# Uninstall capability
def run_uninstall(self):
    """Execute comprehensive uninstall"""
    
    # Read state to know what was installed
    if self.state_file.exists():
        installed = self.state['completed']
    
    # Run uninstall script
    subprocess.run(['bash', 'install/uninstall-bentobox.sh'])
    
    # Removes:
    # - All installed applications
    # - All Docker containers
    # - All customizations
    # - All configs
    # - State and config files
    
    # Result: Near-default Ubuntu

# Recovery from failure
def resume_installation(self):
    """Resume from where we left off"""
    
    # Load state
    completed = self.state['completed']
    failed = self.state['failed']
    
    # Skip completed
    # Retry failed
    # Continue with remaining
```

**Benefits:**
- ✅ Complete uninstall capability
- ✅ Resume from failure
- ✅ Skip already-installed
- ✅ Clean system reset
- ✅ No manual cleanup needed

---

### 10. **Testing & CI/CD**

#### Omakub:
```bash
# Hard to test
# Requires human interaction
# Can't automate
# No CI/CD integration

# Testing approach:
# 1. Spin up VM
# 2. Manually run boot.sh
# 3. Click through all prompts
# 4. Hope it works
```

#### Bentobox:
```yaml
# .github/workflows/test.yml
name: Test Bentobox

on: [push]

jobs:
  test:
    runs-on: ubuntu-24.04
    steps:
      - uses: actions/checkout@v2
      
      - name: Create test config
        run: |
          cat > ~/.bentobox-config.yaml <<EOF
          mode: unattended
          desktop:
            optional_apps: [cursor, chrome]
          languages: [nodejs]
          containers: [portainer]
          EOF
      
      - name: Run installation
        run: bash install.sh
      
      - name: Verify installation
        run: |
          docker ps | grep portainer
          command -v node
          command -v cursor
      
      - name: Test uninstall
        run: bash install/uninstall-bentobox.sh
```

**Benefits:**
- ✅ Fully automated testing
- ✅ CI/CD integration
- ✅ Reproducible builds
- ✅ Config-driven testing
- ✅ No human interaction needed

---

## Why Python + Bash Hybrid?

### Bash Strengths (kept):
- ✅ Perfect for system operations (apt, systemctl, etc.)
- ✅ Shell command execution
- ✅ File manipulation
- ✅ Already written and working

### Python Strengths (added):
- ✅ Better error handling (try/except)
- ✅ Data structures (dicts, lists, JSON, YAML)
- ✅ Subprocess management
- ✅ Threading for GUI
- ✅ GTK integration
- ✅ State management
- ✅ Complex logic

### Best of Both:
```
Python orchestrator (brain)
    ↓
Calls bash workers (hands)
    ↓
Results back to Python (tracking)
```

Each language does what it's best at!

---

## Code Comparison Example

### Installing Docker

#### Omakub Approach:
```bash
# install.sh
set -e
source terminal.sh

# terminal.sh
source terminal/docker.sh

# terminal/docker.sh
# Runs in same shell
# exit would kill everything
# No state tracking

sudo apt install docker-ce
# If this fails → entire install stops
# No record of failure
# Must start over
```

#### Bentobox Approach:
```python
# orchestrator.py
def install_docker(self):
    script = self.omakub_path / 'install/terminal/docker.sh'
    
    # Check if already done
    if 'docker.sh' in self.state['completed']:
        print("✓ Docker already installed, skipping")
        return True
    
    # Run as subprocess
    try:
        result = subprocess.run(
            ['bash', str(script)],
            capture_output=True,
            timeout=300,
            check=False
        )
        
        # Update state
        if result.returncode == 0:
            self.state['completed'].append('docker.sh')
            print("✓ Docker installed successfully")
        else:
            self.state['failed'].append('docker.sh')
            print(f"✗ Docker failed: {result.stderr}")
        
        # Save state
        self.save_state()
        
        # Continue regardless
        return result.returncode == 0
        
    except subprocess.TimeoutExpired:
        print("✗ Docker installation timed out")
        self.state['failed'].append('docker.sh')
        self.save_state()
        return False
```

```bash
# install/terminal/docker.sh
# Same script as Omakub!
# Just runs as subprocess now
# Can use normal exit codes
# Isolated from other components

if command -v docker &> /dev/null; then
    echo "Docker already installed, skipping..."
    exit 0
fi

sudo apt install -y docker-ce docker-ce-cli containerd.io
exit $?
```

**Result:**
- ✅ Docker failure doesn't kill everything
- ✅ State saved after this step
- ✅ Can resume from here if failed
- ✅ GUI shows progress
- ✅ Next component still runs

---

## Performance Comparison

### Sequential Execution (both currently do this):
```
Docker    → Neovim   → Chrome   → VS Code
(2 min)     (3 min)    (1 min)    (2 min)
Total: 8 minutes
```

### Parallel Execution (Bentobox can do this):
```python
# Future enhancement
with ThreadPoolExecutor(max_workers=4) as executor:
    futures = []
    for script in independent_components:
        future = executor.submit(self.run_script, script)
        futures.append(future)
    
    # Wait for all to complete
    for future in as_completed(futures):
        result = future.result()
```

```
Docker    
Neovim    } All run in parallel
Chrome    
VS Code   
Total: 3 minutes (longest component)
```

**Bentobox advantage:** Can add parallel execution without rewriting bash scripts.

---

## GUI Comparison

### Omakub:
```
Terminal only:

? Select apps to install:
  [ ] Cursor
  [ ] VS Code
  [ ] Chrome

Installing...
(text scrolls by)
Done!
```

### Bentobox:
```
GTK Desktop Application:

┌─────────────────────────────────────┐
│ Bentobox Installer            [_][□][×]│
├─────────────────────────────────────┤
│ Welcome │ Components │ Install │ Status │
├─────────────────────────────────────┤
│                                     │
│ ☐ Cursor      ☐ Chrome             │
│ ☐ VS Code     ☐ Alacritty          │
│ ☐ Neovim      ☐ Docker             │
│                                     │
│ Progress: ████████░░░░░░░░░░ 45%   │
│                                     │
│ ✓ Docker installed                 │
│ ✓ Neovim installed                 │
│ ⧗ Installing Chrome...              │
│                                     │
├─────────────────────────────────────┤
│ [🎨 Themes] [🗑️ Uninstall] [▶ Start] │
└─────────────────────────────────────┘
```

**Visual feedback, progress tracking, modern UX.**

---

## Real-World Scenario

### Scenario: Installation fails on VS Code

#### Omakub:
```
1. Installation running...
2. Docker ✓
3. Neovim ✓
4. Chrome ✓
5. VS Code ✗ (Node.js segfault)
6. ENTIRE SCRIPT EXITS
7. No record of what completed
8. Run boot.sh again from scratch
9. Reinstalls Docker (unnecessary)
10. Reinstalls Neovim (unnecessary)
11. Reinstalls Chrome (unnecessary)
12. Tries VS Code again... same error
13. Stuck in loop
```

#### Bentobox:
```
1. Installation running...
2. Docker ✓ → state.json updated
3. Neovim ✓ → state.json updated
4. Chrome ✓ → state.json updated
5. VS Code ✗ (Node.js segfault)
   → Caught by try/except
   → Added to failed list
   → state.json updated
6. Continues to next component
7. Alacritty ✓ → state.json updated
8. Installation completes (except VS Code)

9. User sees in GUI:
   ✓ Docker
   ✓ Neovim
   ✓ Chrome
   ✗ VS Code (click for logs)
   ✓ Alacritty

10. Fix VS Code issue (add error handling)
11. Run install again
12. Reads state.json
13. Skips Docker, Neovim, Chrome, Alacritty
14. Only retries VS Code
15. Success!
```

**Bentobox is fault-tolerant and efficient.**

---

## Code Structure Comparison

### Omakub:
```
omakub/
├── boot.sh                    (entry, downloads repo)
├── install.sh                 (main orchestrator)
├── install/
│   ├── terminal.sh           (sources all terminal/*.sh)
│   ├── desktop.sh            (sources all desktop/*.sh)
│   ├── terminal/
│   │   ├── docker.sh         (sourced)
│   │   ├── app-neovim.sh     (sourced)
│   │   └── ...
│   └── desktop/
│       ├── app-chrome.sh     (sourced)
│       ├── app-vscode.sh     (sourced)
│       └── ...
└── themes/
    └── ...

All orchestration: Bash
All execution: Bash (sourced)
No state persistence
No configuration files
Interactive only
```

### Bentobox:
```
bentobox/
├── boot.sh                           (entry, downloads repo)
├── install.sh                        (thin wrapper)
├── install/
│   ├── orchestrator.py              (Python brain) ⭐
│   ├── gui.py                       (GTK interface) ⭐
│   ├── preflight-check.sh           (system validation) ⭐
│   ├── uninstall-bentobox.sh        (full uninstall) ⭐
│   ├── terminal/
│   │   ├── docker.sh                (subprocess)
│   │   ├── app-neovim.sh            (subprocess)
│   │   └── ... (auto-discovered)
│   └── desktop/
│       ├── app-chrome.sh            (subprocess)
│       ├── app-vscode.sh            (subprocess)
│       └── ... (auto-discovered)
├── themes/
│   └── ...
├── bentobox-config.yaml             (user config) ⭐
├── bentobox-state.json              (installation state) ⭐
└── bentobox-installer.desktop       (GUI launcher) ⭐

Orchestration: Python
Execution: Bash (subprocess)
State: JSON (persistent)
Config: YAML
Modes: Interactive, Unattended, GUI
```

---

## Summary

| Feature | Omakub | Bentobox |
|---------|--------|----------|
| **Language** | Pure Bash | Python + Bash |
| **UI** | Terminal (gum) | Terminal + GTK GUI |
| **State Persistence** | ❌ None | ✅ JSON |
| **Configuration** | ❌ Interactive only | ✅ YAML + Interactive |
| **Error Handling** | ❌ Exit on first error | ✅ Isolated per component |
| **Resume** | ❌ Start over | ✅ Resume from failure |
| **Pre-flight Checks** | ❌ Minimal | ✅ Comprehensive |
| **Uninstall** | ❌ Manual | ✅ Automated |
| **Component Discovery** | ❌ Hardcoded | ✅ Auto-discover |
| **Unattended Mode** | ❌ No | ✅ Yes |
| **AI-Driven** | ❌ No | ✅ Yes |
| **Parallel Execution** | ❌ No | ✅ Possible |
| **Progress Tracking** | ❌ No | ✅ Yes |
| **Logging** | ❌ Terminal only | ✅ Files + GUI + Terminal |
| **CI/CD Integration** | ❌ Hard | ✅ Easy |
| **Script Isolation** | ❌ Sourced (shared env) | ✅ Subprocess (isolated) |
| **Recovery** | ❌ None | ✅ Intelligent |

---

## Why This Matters

### For Users:
- ✅ **Installation doesn't fail completely** if one app has issues
- ✅ **Resume capability** if something goes wrong
- ✅ **Visual progress** instead of text flying by
- ✅ **Easy uninstall** to reset system
- ✅ **Pre-flight checks** catch problems early
- ✅ **Better experience** overall

### For Developers:
- ✅ **Easier to test** (unattended mode)
- ✅ **Easier to debug** (logs, state files)
- ✅ **Easier to extend** (drop in new script)
- ✅ **Better error handling** (Python try/except)
- ✅ **CI/CD integration** (automated testing)

### For AI Agents:
- ✅ **Can generate config** (YAML)
- ✅ **Run unattended** (no human needed)
- ✅ **Check state** (JSON parsing)
- ✅ **Recover from errors** (retry failed components)

---

## The Bottom Line

**Omakub:** Great for simple, one-shot, interactive installations by humans.

**Bentobox:** Production-ready system for complex, resumable, automated installations by humans, AI agents, or CI/CD pipelines.

The Python orchestrator provides the **intelligence and resilience**, while bash scripts do the **actual system work**. Best of both worlds! 🚀

---

## What We Kept from Omakub

- ✅ All the bash installation scripts (they work!)
- ✅ The modular approach (terminal/ and desktop/)
- ✅ Theme system
- ✅ The spirit of "opinionated but flexible"
- ✅ Most of the actual installation logic

## What We Added

- ✅ Python orchestration layer
- ✅ State management
- ✅ Configuration files
- ✅ GTK GUI
- ✅ Pre-flight checks
- ✅ Uninstall system
- ✅ Error isolation
- ✅ Resume capability
- ✅ Unattended mode
- ✅ Better UX

**Result:** Omakub's simplicity + Bentobox's robustness = Production-ready system! 🎉

