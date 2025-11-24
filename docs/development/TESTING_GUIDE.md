# Bentobox Testing Guide

Complete guide to test your custom Omakub fork on Ubuntu 24.04.

---

## 📋 Pre-Testing Checklist

Before you begin testing on your Ubuntu 24.04 desktop:

- [ ] You have a **fresh** Ubuntu 24.04 installation (or are willing to test on existing system)
- [ ] You have internet connection
- [ ] You have sudo privileges
- [ ] You've pushed all changes to https://github.com/languageseed/bentobox

---

## 🚀 STEP 1: Push Changes to GitHub

Run this script on your Mac to push all customizations:

```bash
cd /Users/ben/Documents/bentobox
chmod +x push-to-github.sh
./push-to-github.sh
```

**Or manually:**

```bash
cd /Users/ben/Documents/bentobox/omakub

# Check status
git status

# Stage all changes
git add -A

# Commit
git commit -m "Custom bentobox fork: Professional dev environment"

# Push to your fork
git push origin master
```

**Verify on GitHub:**
Visit https://github.com/languageseed/bentobox and confirm your changes are there.

---

## 🧪 STEP 2: Test Installation on Ubuntu 24.04

### Method 1: One-Line Installation (Recommended)

On your Ubuntu 24.04 desktop, open Terminal and run:

```bash
wget -qO- https://raw.githubusercontent.com/languageseed/bentobox/master/boot.sh | bash
```

This will:
1. Show "Bentobox" ASCII art
2. Clone your fork
3. Start the installation process

### Method 2: Manual Installation (For Debugging)

If you want to see more details or debug:

```bash
# Download boot script
wget https://raw.githubusercontent.com/languageseed/bentobox/master/boot.sh

# Make executable
chmod +x boot.sh

# Run it
./boot.sh
```

---

## 📝 STEP 3: During Installation

### What You'll See:

#### 1. **Initial Screen**
```
________                  __        ___.
\_____  \   _____ _____  |  | ____ _\_ |__
 /   |   \ /     \__   \ |  |/ /  |  \ __ \
/    |    \  Y Y  \/ __ \|    <|  |  / \_\ \
\_______  /__|_|  (____  /__|_ \____/|___  /
        \/      \/     \/     \/         \/

=> Bentobox is for fresh Ubuntu 24.04+ installations only!
=> Custom fork by languageseed - Professional development environment

Begin installation (or abort with ctrl+c)...
```

#### 2. **Optional Apps Selection**
You should see only 4 options (not the original 10+):
```
Select optional apps:
  ☐ 1password
  ☐ Barrier
  ☐ Synergy
  ☐ Tailscale
```

**Test**: Select Barrier and Tailscale

#### 3. **Programming Languages Selection**
```
Select programming languages:
  ☑ Ruby on Rails
  ☑ Node.js
  ☐ Go
  ☐ PHP
  ☐ Python
  ☐ Elixir
  ☐ Rust
  ☐ Java
```

**Test**: Select Node.js and Python

#### 4. **Docker Containers Selection**
```
Select Docker containers to deploy:
  ☑ Portainer
  ☑ OpenWebUI
  ☐ Ollama
```

**Test**: Keep defaults (Portainer + OpenWebUI) and optionally add Ollama

#### 5. **Installation Progress**
Watch for:
- Docker installation
- Container deployment messages
- Application installations
- Wallpaper setup message

#### 6. **Reboot Prompt**
```
Ready to reboot for all settings to take effect?
```

**Select**: Yes

---

## ✅ STEP 4: Post-Installation Verification

After reboot, verify everything is working:

### A. Visual Checks

#### 1. **Wallpaper**
- [ ] Desktop shows: `pexels-pok-rie-33563-2049422.jpg` (mountain landscape)
- [ ] Go to Settings → Appearance → Background
- [ ] Verify 7 wallpapers available

#### 2. **Theme**
- [ ] Tokyo Night theme applied
- [ ] Purple accent color
- [ ] Dark mode enabled

### B. Docker & Containers

#### 1. **Check Docker**
```bash
docker --version
# Should show: Docker version 27.x.x

docker ps
# Should show running containers: portainer, open-webui (and ollama if selected)
```

#### 2. **Access Portainer**
```bash
# Open browser
firefox http://localhost:9000
# OR
google-chrome http://localhost:9000
```

**Expected**:
- Portainer web UI loads
- Prompted to create admin account
- Can see running containers

**Test**:
- [ ] Create admin user
- [ ] Login works
- [ ] Can see containers list
- [ ] Can view container logs
- [ ] Can restart a container

#### 3. **Access OpenWebUI**
```bash
# Open browser
firefox http://localhost:3000
```

**Expected**:
- OpenWebUI interface loads
- Clean chat interface
- Model selection available

**Test**:
- [ ] Interface loads properly
- [ ] Can create account
- [ ] If Ollama installed, can download a model

#### 4. **Test Ollama (if installed)**
```bash
# Check Ollama running
docker ps | grep ollama

# Download a small model
docker exec -it ollama ollama pull llama3.2:1b

# Test it
docker exec -it ollama ollama run llama3.2:1b
# Type: "Hello, who are you?"
# Should get a response from the AI
```

### C. Applications Installed

#### 1. **Check Installed Apps**
```bash
# VS Code
code --version

# Chrome
google-chrome --version

# Neovim
nvim --version

# Git
git --version
```

#### 2. **Check Optional Apps**
```bash
# Barrier (if selected)
barrier --version

# Tailscale (if selected)
tailscale version
```

#### 3. **Verify Removed Apps NOT Installed**
```bash
# These should all fail (return "not found")
spotify --version
zoom --version
signal-desktop --version
obsidian --version
steam --version
lazydocker --version
```

**Expected**: All commands fail - apps are not installed ✅

### D. Tailscale Testing (if installed)

```bash
# Start Tailscale
sudo tailscale up

# Browser should open for authentication
# Login or create free account

# Check status
tailscale status

# Get your IP
tailscale ip
# Should show: 100.x.x.x

# Test (from another device with Tailscale)
# SSH: ssh user@100.x.x.x
# Portainer: http://100.x.x.x:9000
```

### E. Barrier Testing (if installed)

```bash
# Launch Barrier
barrier

# Configure as Server
# Click "Configure Server"
# Test with another computer as client
```

---

## 🔍 STEP 5: Detailed Testing Checklist

### Core System
- [ ] System boots properly after installation
- [ ] GNOME desktop environment working
- [ ] Terminal (Alacritty) opens
- [ ] No errors in system logs: `journalctl -xe`

### Docker & Containers
- [ ] Docker installed: `docker --version`
- [ ] Docker service running: `sudo systemctl status docker`
- [ ] Portainer container running
- [ ] Portainer accessible at http://localhost:9000
- [ ] OpenWebUI container running
- [ ] OpenWebUI accessible at http://localhost:3000
- [ ] Ollama container running (if selected)
- [ ] Containers restart after reboot

### Applications
- [ ] VS Code launches and works
- [ ] Chrome launches and works
- [ ] Neovim works: `nvim test.txt`
- [ ] Terminal tools work: `fzf`, `rg`, `bat`
- [ ] GitHub CLI works: `gh --version`
- [ ] LibreOffice works
- [ ] VLC works

### Optional Apps
- [ ] Barrier installed (if selected)
- [ ] Synergy installed (if selected)
- [ ] Tailscale installed (if selected)
- [ ] 1Password installed (if selected)

### Programming Languages
- [ ] Node.js: `node --version` (if selected)
- [ ] Python: `python --version` (if selected)
- [ ] Ruby: `ruby --version` (if selected)
- [ ] mise installed: `mise --version`

### Customizations
- [ ] Custom wallpaper displayed
- [ ] All 7 wallpapers in Settings
- [ ] Wallpapers in: `~/.local/share/backgrounds/omakub/`
- [ ] Tokyo Night theme colors applied

### Removed Apps (Should NOT be installed)
- [ ] Spotify not found
- [ ] Zoom not found
- [ ] Dropbox not found
- [ ] Signal not found
- [ ] Obsidian not found
- [ ] Steam not found
- [ ] Minecraft not found
- [ ] Windsurf not found
- [ ] Zed not found
- [ ] Doom Emacs not found
- [ ] WhatsApp not in applications
- [ ] lazydocker not found

### Database Containers (Should NOT be running)
- [ ] MySQL container NOT running
- [ ] Redis container NOT running
- [ ] PostgreSQL container NOT running

---

## 🐛 Troubleshooting

### Issue: Installation Fails

**Solution 1**: Check internet connection
```bash
ping google.com
```

**Solution 2**: Check for errors
```bash
# Look at installation logs
journalctl -xe

# Check if git is installed
git --version
```

**Solution 3**: Run manually step-by-step
```bash
# Download and inspect boot.sh
wget https://raw.githubusercontent.com/languageseed/bentobox/master/boot.sh
cat boot.sh

# Run with debugging
bash -x boot.sh
```

### Issue: Docker Not Working

```bash
# Check Docker service
sudo systemctl status docker

# Start Docker
sudo systemctl start docker

# Add user to docker group (if not done)
sudo usermod -aG docker $USER

# Logout and login again
```

### Issue: Containers Not Running

```bash
# List all containers
docker ps -a

# Check container logs
docker logs portainer
docker logs open-webui
docker logs ollama

# Restart container
docker restart portainer
```

### Issue: Portainer Not Accessible

```bash
# Check if port is listening
netstat -tlnp | grep 9000

# Check firewall
sudo ufw status

# Try accessing
curl http://localhost:9000
```

### Issue: Wallpaper Not Set

```bash
# Check wallpapers copied
ls -la ~/.local/share/backgrounds/omakub/

# Manually set wallpaper
gsettings set org.gnome.desktop.background picture-uri "file://$HOME/.local/share/backgrounds/omakub/pexels-pok-rie-33563-2049422.jpg"
```

### Issue: Tailscale Not Working

```bash
# Check Tailscale status
sudo systemctl status tailscaled

# Start Tailscale
sudo tailscale up

# Check logs
sudo journalctl -u tailscaled
```

---

## 📊 Performance Testing

### System Resources After Installation

```bash
# Check RAM usage
free -h

# Check disk usage
df -h

# Check running processes
htop

# Check Docker stats
docker stats
```

**Expected Resources:**
- RAM: ~2-3GB used (with containers running)
- Disk: ~15-20GB used
- Docker containers: ~500MB RAM total

---

## 📸 Screenshot Checklist

Take screenshots of:
1. [ ] Initial Bentobox ASCII art screen
2. [ ] Optional apps selection (showing only 4 apps)
3. [ ] Container selection screen
4. [ ] Desktop with custom wallpaper after reboot
5. [ ] Portainer web UI
6. [ ] OpenWebUI interface
7. [ ] `docker ps` output
8. [ ] Settings → Appearance → Background (showing 7 wallpapers)

---

## ✅ Success Criteria

Installation is successful if:

1. ✅ All core applications installed and working
2. ✅ Docker + Portainer + OpenWebUI running
3. ✅ Custom wallpaper displayed
4. ✅ Selected optional apps working (Barrier, Tailscale)
5. ✅ Removed apps are NOT installed
6. ✅ Database containers NOT running
7. ✅ No critical errors in logs
8. ✅ System is stable and usable

---

## 🎯 Quick Test Commands

Run all these to quickly verify installation:

```bash
#!/bin/bash

echo "=== Testing Bentobox Installation ==="
echo ""

echo "1. Docker:"
docker --version
docker ps --format "table {{.Names}}\t{{.Status}}"
echo ""

echo "2. Containers accessible:"
curl -s -o /dev/null -w "Portainer: %{http_code}\n" http://localhost:9000
curl -s -o /dev/null -w "OpenWebUI: %{http_code}\n" http://localhost:3000
echo ""

echo "3. Applications:"
code --version 2>/dev/null && echo "VS Code: ✅" || echo "VS Code: ❌"
google-chrome --version 2>/dev/null && echo "Chrome: ✅" || echo "Chrome: ❌"
nvim --version 2>/dev/null && echo "Neovim: ✅" || echo "Neovim: ❌"
echo ""

echo "4. Optional Apps:"
barrier --version 2>/dev/null && echo "Barrier: ✅" || echo "Barrier: Not installed"
tailscale version 2>/dev/null && echo "Tailscale: ✅" || echo "Tailscale: Not installed"
echo ""

echo "5. Removed Apps (should all fail):"
spotify 2>/dev/null && echo "Spotify: ❌ SHOULD NOT BE HERE" || echo "Spotify: ✅ Correctly removed"
zoom 2>/dev/null && echo "Zoom: ❌ SHOULD NOT BE HERE" || echo "Zoom: ✅ Correctly removed"
echo ""

echo "6. Wallpapers:"
ls -1 ~/.local/share/backgrounds/omakub/ 2>/dev/null | wc -l | xargs echo "Wallpapers available:"
echo ""

echo "7. Current wallpaper:"
gsettings get org.gnome.desktop.background picture-uri
echo ""

echo "=== Test Complete ==="
```

Save as `test-bentobox.sh` and run: `bash test-bentobox.sh`

---

## 📝 Test Report Template

After testing, document results:

```
# Bentobox Test Report

Date: ___________
Ubuntu Version: 24.04
Hardware: ___________

## Installation
- [ ] Boot script ran successfully
- [ ] Installation completed without errors
- [ ] System rebooted successfully

## Applications
- [ ] Core apps working: _____/_____ (count)
- [ ] Optional apps working: _____/_____ (count)
- [ ] Removed apps verified absent: _____/_____ (count)

## Docker & Containers
- [ ] Docker running
- [ ] Portainer accessible
- [ ] OpenWebUI accessible
- [ ] Ollama working (if selected)

## Customizations
- [ ] Custom wallpaper set
- [ ] All 7 wallpapers available
- [ ] Theme applied correctly

## Issues Found
1. ___________
2. ___________

## Overall Result
- [ ] PASS - Ready for production
- [ ] FAIL - Needs fixes

## Notes
___________
```

---

## 🎉 After Successful Testing

Once testing passes:

1. **Document any issues** found
2. **Fix issues** in your fork
3. **Test again** if needed
4. **Share your fork** with others
5. **Create a release tag**:
```bash
git tag -a v1.0 -m "Bentobox v1.0 - Professional dev environment"
git push origin v1.0
```

6. **Update README** on GitHub with:
   - What's different from original Omakub
   - Installation instructions
   - Screenshots
   - Use cases

---

## 🔄 Next Steps After Testing

- [ ] Fix any issues found
- [ ] Update documentation
- [ ] Create GitHub Release
- [ ] Add screenshots to README
- [ ] Share with community
- [ ] Deploy to your production systems

---

**Good luck with testing! Your custom Bentobox fork is ready! 🚀**

