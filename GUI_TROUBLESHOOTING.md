# Bentobox GUI - Troubleshooting Guide

## The GUI won't launch

### Problem: "bentobox does not launch"

There are several possible reasons:

### 1. Running over SSH (most common)

**Symptom:**
```
❌ No display detected. GUI requires a graphical session.
   Run this from the desktop, not over SSH.
```

**Solution:**
The GUI requires a graphical desktop session. You cannot run it over SSH without X11 forwarding.

**To launch properly:**
1. Physically sit at the computer OR use remote desktop (not SSH)
2. Log into GNOME desktop
3. Press `Ctrl+Alt+T` to open terminal
4. Run: `bentobox-gui`

**Alternative for SSH users:**
Use the command-line version instead:
```bash
# Interactive
cd ~/.local/share/omakub
bash ./install.sh

# Or direct orchestrator
python3 install/orchestrator.py
```

### 2. Missing Dependencies

**Check if installed:**
```bash
bash ~/.local/share/omakub/test-gui.sh
```

This will tell you exactly what's missing.

**Install dependencies manually:**
```bash
sudo apt install python3-gi gir1.2-gtk-3.0 gir1.2-vte-2.91 zenity
python3 -m pip install --user pyyaml
```

### 3. GUI File Not Found

**Check if GUI exists:**
```bash
ls -la ~/.local/share/omakub/gui.py
# OR
ls -la ~/.local/share/omakub/install/gui.py
```

**Reinstall if missing:**
```bash
cd ~/.local/share/omakub
bash install-gui.sh
```

### 4. Python Errors

**Test for syntax errors:**
```bash
python3 -m py_compile ~/.local/share/omakub/gui.py
```

If errors appear, the GUI file may be corrupted. Re-sync or re-download.

### 5. Launcher Not Installed

**Check if bentobox-gui command exists:**
```bash
which bentobox-gui
```

Should output: `/usr/local/bin/bentobox-gui`

**Reinstall launcher:**
```bash
cd ~/.local/share/omakub
sudo cp bentobox-gui.sh /usr/local/bin/bentobox-gui
sudo chmod +x /usr/local/bin/bentobox-gui
```

## Common Error Messages

### "Failed to load module 'canberra-gtk-module'"

**This is harmless.** The GUI will work fine. It's just a missing sound theme.

**Optional fix:**
```bash
sudo apt install libcanberra-gtk3-module
```

### "Gtk-WARNING: cannot open display"

You're trying to run the GUI over SSH or outside a graphical session.

**Solution:** Run from actual desktop (see #1 above)

### "ModuleNotFoundError: No module named 'yaml'"

PyYAML not installed.

**Solution:**
```bash
python3 -m pip install --user pyyaml
```

### "ModuleNotFoundError: No module named 'gi'"

GTK bindings not installed.

**Solution:**
```bash
sudo apt install python3-gi gir1.2-gtk-3.0
```

## Testing the GUI

### Quick Test (from desktop terminal)

```bash
bash ~/.local/share/omakub/test-gui.sh
```

This will:
- Check for graphical session
- Verify all dependencies
- Launch the GUI if everything is OK

### Manual Launch Methods

**Method 1: From command**
```bash
bentobox-gui
```

**Method 2: From menu**
1. Open **Applications**
2. Search for "Bentobox"
3. Click **Bentobox Installer**

**Method 3: Direct Python**
```bash
cd ~/.local/share/omakub
python3 gui.py
# OR
python3 install/gui.py
```

## Still Not Working?

### Get Detailed Error Output

```bash
bentobox-gui 2>&1 | tee ~/bentobox-gui-error.log
cat ~/bentobox-gui-error.log
```

### Check System Logs

```bash
journalctl --user -xe | grep -i bentobox
```

### Verify Desktop Environment

```bash
echo "DISPLAY: $DISPLAY"
echo "WAYLAND_DISPLAY: $WAYLAND_DISPLAY"
echo "XDG_SESSION_TYPE: $XDG_SESSION_TYPE"
echo "DESKTOP_SESSION: $DESKTOP_SESSION"
```

Should show values (not empty). If all empty, you're not in a graphical session.

## Workarounds

### If GUI Absolutely Won't Work

Use the command-line orchestrator directly:

**1. Edit config manually:**
```bash
nano ~/.bentobox-config.yaml
```

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

**2. Run orchestrator:**
```bash
cd ~/.local/share/omakub
python3 install/orchestrator.py
```

**3. Check results:**
```bash
cat ~/.bentobox-state.json | python3 -m json.tool
```

## Getting Help

If none of these solutions work:

1. **Gather information:**
   ```bash
   # System info
   lsb_release -a
   python3 --version
   
   # Installed packages
   dpkg -l | grep -E 'python3-gi|gtk|vte'
   
   # File locations
   find ~/.local/share/omakub -name "*.py" -o -name "*gui*"
   
   # Error log
   bentobox-gui 2>&1 | tee ~/error.log
   ```

2. **Include in your report:**
   - Operating system version
   - Python version
   - Error messages (exact text)
   - How you're trying to launch (SSH? Desktop? Remote desktop?)
   - Output from test-gui.sh

## Alternative: Remote Desktop

If you need remote access WITH GUI:

### Option 1: VNC
```bash
sudo apt install tightvncserver
vncserver :1
```

Then connect with VNC client to `yourserver:5901`

### Option 2: RDP (xrdp)
```bash
sudo apt install xrdp
sudo systemctl enable xrdp
```

Then connect with Windows Remote Desktop

### Option 3: SSH with X11 Forwarding
```bash
ssh -X user@host
bentobox-gui
```

This is SLOW but works in a pinch.

