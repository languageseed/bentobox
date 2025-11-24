# Bentobox Installation System - Architectural Improvements

## Problem Summary

The original Bentobox installation system (forked from Omakub) suffered from:

1. **Fragile error handling**: `set -e` caused the entire installation to crash on any single error
2. **Infinite loops**: Scripts could source themselves, causing endless recursion
3. **No state tracking**: Re-running installations would reinstall everything
4. **Poor observability**: Hard to debug what failed and why
5. **Bash limitations**: No structured data, limited error handling capabilities

## Solution: Hybrid Python/Bash Architecture

### New Architecture

```
┌─────────────────────────────────────┐
│   install.sh (thin wrapper)         │
│   - Checks Python                   │
│   - Installs dependencies           │
│   - Calls orchestrator.py           │
└─────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────┐
│   orchestrator.py (brain)           │
│   - Discovers components            │
│   - Runs preflight checks           │
│   - Loads user config               │
│   - Tracks state                    │
│   - Manages execution               │
│   - Handles errors gracefully       │
└─────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────┐
│   Individual bash scripts (workers) │
│   - Self-contained                  │
│   - Check if already installed      │
│   - Install component               │
│   - Exit with status code           │
└─────────────────────────────────────┘
```

### Key Changes

#### 1. Python Orchestrator (`install/orchestrator.py`)

**Responsibilities:**
- Component discovery (scans `install/terminal/`, `install/desktop/`, `install/desktop/optional/`)
- Preflight checks (detects already-installed components)
- State management (saves progress to `~/.bentobox-state.json`)
- Configuration loading (reads `~/.bentobox-config.yaml`)
- Graceful error handling (continues on failure, reports at end)
- Progress tracking and reporting

**Benefits:**
- Proper try/except error handling
- Native YAML support
- Structured data (JSON state file)
- Clean subprocess management
- Detailed logging

#### 2. Bash Script Modifications

**Changed:**
- All `return 0` → `exit 0` (scripts no longer sourced)
- All `return 1` → `exit 1`
- All `return 2` → `exit 2`

**Why:**
- Scripts are now called as subprocesses, not sourced
- Clean exit codes for success/failure
- No shared state between scripts
- No accidental recursion

#### 3. State Management

**State File** (`~/.bentobox-state.json`):
```json
{
  "components": {
    "docker": {
      "status": "already_installed",
      "error": null
    },
    "neovim": {
      "status": "installed",
      "error": null
    },
    "some_failed_component": {
      "status": "failed",
      "error": "Exit code: 1"
    }
  }
}
```

**Component Statuses:**
- `not_installed` - Not yet attempted
- `already_installed` - Detected as installed during preflight
- `installing` - Currently being installed
- `installed` - Successfully installed this run
- `failed` - Installation failed (but we continued)
- `skipped` - User chose not to install

### Installation Flow

```
1. Load config & state
   ├─ Read ~/.bentobox-config.yaml
   └─ Read ~/.bentobox-state.json

2. Discover components
   ├─ Scan install/terminal/*.sh
   ├─ Scan install/desktop/app-*.sh
   └─ Scan install/desktop/optional/*.sh

3. Run preflight checks
   ├─ Test if components already installed
   └─ Update component status

4. Apply user preferences
   └─ Mark optional components based on config

5. Build installation queue
   ├─ Filter out already_installed
   ├─ Filter out skipped
   └─ Order by dependencies (future)

6. Install each component
   ├─ Call bash script as subprocess
   ├─ Set 5-minute timeout per component
   ├─ Continue on failure
   └─ Save state after each component

7. Report results
   ├─ ✅ Successful: X
   ├─ ⚠️  Failed: Y
   ├─ ⏭️  Skipped: Z
   └─ 📦 Already installed: W
```

## Testing Results

Tested on fresh Ubuntu 24.04 installation (leaf):

### First Run
```
✓ Discovered 45 components
✓ Detected 11 already installed
📋 Queued 16 for installation
✅ Installed 16 successfully
⚠️  Failed 0
```

### Second Run (Re-run test)
```
✓ Discovered 45 components
✓ Detected 27 already installed (increased from first run)
📋 Queued 0 for installation
✅ All components already installed!
```

### Error Handling
- Flatpak permission errors: Continued
- GitHub API failures: Continued
- Network timeouts: Continued
- Package conflicts: Detected and skipped

## Benefits

1. **Resilient**: Single component failures don't crash entire installation
2. **Idempotent**: Can re-run safely without reinstalling
3. **Observable**: Clear progress reporting and state tracking
4. **Debuggable**: JSON state file + detailed logging
5. **Maintainable**: Clean separation between orchestration (Python) and installation (Bash)
6. **Extensible**: Easy to add new components (just add script + check command)

## Migration Path

### For Users
- Old: `bash install.sh`
- New: `bash install.sh` (same command, new orchestrator)
- State automatically tracked
- Config optional but recommended

### For Developers
- Add new component: Create `install/terminal/app-myapp.sh`
- Add check: Update `_get_check_command()` in `orchestrator.py`
- Test: `python3 install/orchestrator.py`

## Future Enhancements

1. **Dependency resolution**: Automatically order components by prerequisites
2. **Parallel installation**: Install independent components simultaneously
3. **Retry logic**: Auto-retry failed components with exponential backoff
4. **Rollback**: Undo installations on critical failures
5. **Web UI**: Browser-based installation progress tracking
6. **Remote orchestration**: Ansible/Puppet integration

## Files Modified

- `install.sh` - Replaced with thin Python wrapper
- `install/orchestrator.py` - New Python orchestrator
- `install/**/*.sh` - Changed `return` → `exit` (97 files)

## Configuration

### User Config (`~/.bentobox-config.yaml`)
```yaml
mode: unattended
desktop:
  optional_apps:
    - cursor
    - tailscale
languages:
  - "Node.js"
  - "Python"
containers:
  - Portainer
  - OpenWebUI
```

### State File (`~/.bentobox-state.json`)
- Auto-generated
- Tracks installation progress
- Safe to delete (will regenerate)

## Conclusion

This refactor transforms Bentobox from a fragile bash monolith into a robust, maintainable installation system that gracefully handles errors, tracks state, and provides clear feedback. The hybrid approach leverages Python's strengths for orchestration while keeping the existing bash scripts for actual installation work.

