# WinBoat Testing Guide - Quick Start

## ✅ Installation Status

**System**: leaf (192.168.0.104)  
**WinBoat Location**: `~/winboat/winboat-0.8.7-x86_64.AppImage`  
**Desktop Entry**: `~/.local/share/applications/winboat.desktop`  
**Prerequisites**: ✅ QEMU/KVM, libvirt, Docker, virt-manager installed

## 🎯 Testing Roadmap

Since WinBoat is now installed on `leaf`, you can proceed with GUI testing directly from the graphical environment. Here's your testing workflow:

---

## Phase 1: Initial Launch Testing (10-15 minutes)

### Step 1: Launch WinBoat

**From Terminal** (if SSH):
```bash
ssh -X leaf
cd ~/winboat
./winboat-0.8.7-x86_64.AppImage
```

**From Desktop** (if at the machine):
- Open application menu and search for "WinBoat"
- OR: Double-click the AppImage in file manager

### Step 2: First Impressions Checklist

- [ ] Application launches without errors
- [ ] GUI appears and is responsive
- [ ] Clear welcome screen or setup wizard
- [ ] System requirements check passes
- [ ] Error messages (if any): ___________________

### Step 3: Initial Configuration

WinBoat will likely prompt you to:
1. **Configure resources** for the Windows VM:
   - Recommended: 4 CPU cores, 8GB RAM, 50GB disk
   - Leaf specs: 6-core CPU, 16GB RAM available
   - Set to: ___ cores, ___ GB RAM, ___ GB disk

2. **Download Windows** (or use existing image):
   - This may take 30-60 minutes
   - Note: Some versions auto-download, others need ISO
   - Method used: _________________________

---

## Phase 2: Windows Installation (30-60 minutes)

### During Installation

Monitor and document:
- [ ] Installation progress is visible
- [ ] Clear status messages
- [ ] No errors or warnings
- [ ] Time estimate accuracy

**Actual time taken**: _____ minutes

### Post-Installation

- [ ] Windows desktop appears
- [ ] Resolution is appropriate
- [ ] Mouse and keyboard work
- [ ] Can interact with Windows Start menu

---

## Phase 3: Core Functionality Testing (20-30 minutes)

### 3.1 Basic Windows Operations
- [ ] Start Menu opens and works
- [ ] Launch Calculator (should work seamlessly)
- [ ] Launch Notepad and type some text
- [ ] Open File Explorer and browse directories
- [ ] Check network connectivity (open Edge browser)

### 3.2 Filesystem Integration 🔥 **CRITICAL TEST**
This is WinBoat's killer feature - seamless file access!

```bash
# From Linux side, create a test file:
echo "Test from Linux" > ~/winboat-test.txt
```

**In Windows**:
- [ ] Can you see `winboat-test.txt` in a mapped drive?
- [ ] Where is it mounted? (Usually Z:\ or similar): _______
- [ ] Open the file in Windows Notepad
- [ ] Edit and save the file
- [ ] Go back to Linux and verify changes saved

**From Windows, create a file**:
- [ ] Create `windows-test.txt` on the mapped Linux drive
- [ ] Return to Linux terminal: `ls -l ~/windows-test.txt`
- [ ] Can you read it from Linux?: _______

### 3.3 Clipboard Integration
- [ ] Copy text in Linux → paste in Windows Notepad
- [ ] Copy text in Windows → paste in Linux text editor
- [ ] Note any issues: _________________________

### 3.4 Window Management
- [ ] Windows apps appear as separate Linux windows
- [ ] Can minimize/maximize/close
- [ ] Alt+Tab shows Windows apps
- [ ] Window decorations look correct
- [ ] Can move windows between monitors (if multi-monitor)

---

## Phase 4: Application Testing (30-45 minutes)

### Test 1: Web Browser
```
Install: Chrome or Firefox in Windows
Test: Browse to google.com, youtube.com
Result: ☐ Works perfectly ☐ Minor issues ☐ Major issues ☐ Broken
Notes: _________________________________
```

### Test 2: Office Document
```
Option 1: Open Office 365 (online version) in browser
Option 2: Install LibreOffice in Windows
Test: Create and edit a document
Result: ☐ Works perfectly ☐ Minor issues ☐ Major issues ☐ Broken
Notes: _________________________________
```

### Test 3: Image Editor (if time permits)
```
Install: Paint.NET or GIMP for Windows
Test: Open an image, edit, save
Result: ☐ Works perfectly ☐ Minor issues ☐ Major issues ☐ Broken
Notes: _________________________________
```

---

## Phase 5: Performance & Stability (15-20 minutes)

### 5.1 Resource Usage

**From Linux terminal while WinBoat is running**:
```bash
# Check RAM usage
free -h
# CPU usage
top -b -n 1 | grep winboat
# Docker containers
docker ps
docker stats --no-stream
```

**Document**:
- RAM used by WinBoat: _____ GB
- CPU usage (idle): _____ %
- CPU usage (active): _____ %
- Disk space used: _____ GB

### 5.2 Performance Feel
- **Typing lag**: ☐ None ☐ Slight ☐ Noticeable ☐ Severe
- **Mouse responsiveness**: ☐ Excellent ☐ Good ☐ Fair ☐ Poor
- **Window dragging**: ☐ Smooth ☐ Acceptable ☐ Laggy
- **Overall feel**: ☐ Native-like ☐ Good ☐ Usable ☐ Sluggish

### 5.3 Stress Test
- [ ] Open 5+ Windows apps simultaneously
- [ ] Switch between them rapidly
- [ ] System remains responsive: ☐ Yes ☐ Somewhat ☐ No
- [ ] Any crashes or freezes: _______________________

---

## Phase 6: Shutdown & Restart Testing (5 minutes)

### Test 1: Graceful Shutdown
```bash
# Close WinBoat application normally
# Check if Docker containers stop:
docker ps
```
- [ ] WinBoat closes cleanly
- [ ] Docker containers stop automatically
- [ ] No error messages

### Test 2: Restart Test
```bash
# Launch WinBoat again
~/winboat/winboat-0.8.7-x86_64.AppImage
```
- [ ] Restarts quickly (< 30 seconds)
- [ ] Windows resumes to desktop
- [ ] Previous files/settings preserved
- [ ] Time to Windows desktop: _____ seconds

---

## 🎯 Critical Decision Points

After testing, answer these questions to determine Bentobox inclusion:

### 1. **Stability** ⭐⭐⭐⭐⭐
☐ Rock solid - No crashes, no data loss  
☐ Stable - Minor glitches, but usable  
☐ Beta quality - Occasional crashes  
☐ Unstable - Frequent issues  

### 2. **Performance** ⭐⭐⭐⭐⭐
☐ Excellent - Feels nearly native  
☐ Good - Perfectly usable  
☐ Acceptable - Slight lag, but workable  
☐ Poor - Too slow for practical use  

### 3. **Ease of Use** ⭐⭐⭐⭐⭐
☐ Very easy - Just works  
☐ Moderate - Some learning curve  
☐ Complex - Requires technical knowledge  
☐ Difficult - Frequent troubleshooting needed  

### 4. **Value Proposition** ⭐⭐⭐⭐⭐
☐ High - Solves real problems  
☐ Medium - Useful for specific users  
☐ Low - Niche use cases  
☐ Unclear - Better alternatives exist  

---

## 📊 Final Recommendation

### Include in Bentobox?

**☐ YES - Ready for bentobox optional apps**
- Stable enough for daily use
- Clear value for professional users (Adobe, Office)
- Installation script works well

**☐ YES WITH WARNINGS - Beta/Advanced users only**
- Works but has rough edges
- Requires troubleshooting skills
- Label as "BETA" in bentobox

**☐ NOT YET - Wait for maturity**
- Too many stability issues
- Performance not acceptable
- Wait for v1.0 or later

**☐ NO - Not suitable for bentobox**
- Fundamental issues
- Better alternatives exist (WINE, etc.)
- Too complex for bentobox users

---

## 📝 Testing Notes Template

```
═══════════════════════════════════════════════════
WinBoat Test Session Report
═══════════════════════════════════════════════════

Date: _____________
Tester: labadmin
System: leaf (6-core, 16GB RAM, ZFS)
WinBoat Version: 0.8.7
Ubuntu Version: 24.04

─────────────────────────────────────────────────────
INSTALLATION
─────────────────────────────────────────────────────
Time to complete: _____ minutes
Difficulty: ☐ Easy ☐ Moderate ☐ Difficult
Issues encountered:



─────────────────────────────────────────────────────
FUNCTIONALITY
─────────────────────────────────────────────────────
Basic operations: ☐ Pass ☐ Fail
File system integration: ☐ Pass ☐ Fail
Clipboard sharing: ☐ Pass ☐ Fail
Window management: ☐ Pass ☐ Fail

Applications tested:
1. _________________  Result: _______________
2. _________________  Result: _______________
3. _________________  Result: _______________

─────────────────────────────────────────────────────
PERFORMANCE
─────────────────────────────────────────────────────
RAM usage: _____ GB
CPU usage: _____ %
Responsiveness: ☐ Excellent ☐ Good ☐ Fair ☐ Poor

─────────────────────────────────────────────────────
STABILITY
─────────────────────────────────────────────────────
Crashes: _____ 
Errors: _____
Uptime tested: _____ hours
Recovery: ☐ Excellent ☐ Good ☐ Fair ☐ Poor

─────────────────────────────────────────────────────
NOTABLE ISSUES
─────────────────────────────────────────────────────
1. 
2. 
3. 

─────────────────────────────────────────────────────
OVERALL ASSESSMENT
─────────────────────────────────────────────────────
Rating: ___/10

Strengths:
• 
• 
• 

Weaknesses:
• 
• 
• 

Recommendation: ☐ Include ☐ Include w/warnings ☐ Not yet ☐ No

═══════════════════════════════════════════════════
```

---

## 🚀 Ready to Start?

1. **Log into leaf graphically** (or use `ssh -X leaf`)
2. **Launch WinBoat**: `~/winboat/winboat-0.8.7-x86_64.AppImage`
3. **Follow the phases above** and document your findings
4. **Report back** with results!

---

## 📚 Reference Documentation

- Full Testing Plan: `TESTING_PLAN.md`
- Technical Details: `README.md`
- Evaluation Checklist: `EVALUATION_CHECKLIST.md`
- Deployment Notes: `DEPLOYMENT_NOTES.md`
- Test Report Template: `TESTING_REPORT.md`

---

**Good luck with testing! 🎉**

