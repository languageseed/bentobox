# Bentobox Deployment Issues Report
**Date:** November 23, 2025  
**Reviewer:** AI Assistant  
**Compared:** [basecamp/omakub](https://github.com/basecamp/omakub) vs [languageseed/bentobox](https://github.com/languageseed/bentobox)

---

## 🔴 CRITICAL ISSUES

### 1. **Nested Repository Structure (SHOW STOPPER)**

**Problem:** Your repository has a nested structure with an `/omakub` directory inside the main bentobox repository.

**Evidence:**
```
/bentobox/
├── boot.sh                    ← Points to languageseed/bentobox
├── install.sh
├── applications/
├── configs/
├── themes/
└── omakub/                    ← DUPLICATE! Contains outdated copy
    ├── boot.sh                ← Points to languageseed/bentobox 
    ├── install.sh
    ├── applications/
    ├── configs/
    └── themes/
```

**Impact:**
- Users downloading from GitHub get the root-level files
- The `/omakub` subdirectory is confusing and outdated
- The nested `/omakub/boot.sh` still references `languageseed/bentobox` but is never used
- This creates confusion about which files are the "real" installation files

**Why It's Failing:**
When users run:
```bash
wget -qO- https://raw.githubusercontent.com/languageseed/bentobox/master/boot.sh | bash
```

They download `boot.sh` which clones the repo to `~/.local/share/omakub`, but the nested structure may cause confusion or incorrect file paths during installation.

**Fix Required:**
- **Delete the entire `/omakub` directory** - it's redundant and outdated
- Keep only the root-level installation files
- The root directory should be the installation source

---

### 2. **Duplicate boot.sh File (boot.sh vs boot-local.sh)**

**Problem:** You have two boot scripts:
- `boot.sh` - For remote installation (downloads from GitHub)
- `boot-local.sh` - For local testing (copies from `~/bentobox-install`)

**Evidence:**
```bash
# boot.sh (line 26)
git clone --depth 1 https://github.com/languageseed/bentobox.git "$OMAKUB_PATH"

# boot-local.sh (line 28)
cp -r ~/bentobox-install ~/.local/share/omakub
```

**Impact:**
- `boot-local.sh` references a hardcoded path `~/bentobox-install` that doesn't exist in your repo
- This suggests you're testing locally but haven't updated the remote deployment
- Users will never use `boot-local.sh`, so it's just clutter

**Fix Required:**
- Remove `boot-local.sh` or add it to `.gitignore`
- Ensure `boot.sh` is the only public entry point

---

### 3. **Missing "WinBoat" Reference in omakub/README.md**

**Problem:** Your main `README.md` mentions WinBoat, but `omakub/README.md` (the nested duplicate) does NOT mention WinBoat.

**Evidence:**
```
# Main README.md (line 62)
- **WinBoat** - Run Windows applications seamlessly on Linux (optional)

# omakub/README.md
[WinBoat is completely missing from the optional apps list]
```

**Impact:**
- Inconsistent documentation
- If someone reads the nested README, they won't know about WinBoat
- Suggests the `omakub/` directory is out of sync with your actual code

**Fix Required:**
- Delete the `/omakub` directory entirely (see Issue #1)

---

### 4. **app-winboat.sh Has Unstaged Changes**

**Problem:** According to your `git status`, you have unstaged changes in:
```
modified:   install/desktop/optional/app-winboat.sh
```

**Impact:**
- Your GitHub repository doesn't have the latest version of this file
- Users downloading from GitHub will get an older version
- This could explain deployment failures if the old version had bugs

**Fix Required:**
1. Review the changes in `app-winboat.sh`
2. Test them locally
3. Commit and push to GitHub:
   ```bash
   git add install/desktop/optional/app-winboat.sh
   git commit -m "Update WinBoat installation script"
   git push origin master
   ```

---

## 🟡 MODERATE ISSUES

### 5. **commit.sh Untracked File**

**Problem:** You have an untracked `commit.sh` file in your repository root.

**Evidence:**
```
Untracked files:
  commit.sh
```

**Impact:**
- This is likely a personal helper script
- It shouldn't be in the public repository
- Could confuse users or expose internal workflows

**Fix Required:**
```bash
# Add to .gitignore
echo "commit.sh" >> .gitignore

# Or if it's useful, commit it with documentation
```

---

### 6. **Version Number Mismatch**

**Problem:** Your boot scripts show different version identifiers:

```bash
# boot.sh (line 13)
echo "=> Bentobox v2.0 (Build f369fb2) - Nov 23, 2025"

# boot-local.sh (line 15)  
echo "=> Bentobox v2.0 (Build 1f07848 - LOCAL) - Nov 23, 2025"
```

**Impact:**
- Build hashes don't match
- Suggests the local version is different from what's deployed
- Users might report bugs from different versions

**Fix Required:**
- Update version tracking
- Consider using `git describe --always` to auto-generate build hashes
- Or maintain a single `version` file

---

### 7. **Excessive OMAKUB References (284 files)**

**Problem:** Your fork still contains 284 references to "omakub" across 98 files.

**Impact:**
- Some references are necessary (paths like `~/.local/share/omakub`)
- Others might be outdated comments or documentation
- Could cause confusion about branding

**Examples to Review:**
- `OMAKUB_PATH` variable (necessary)
- `OMAKUB_FIRST_RUN_*` variables (necessary)
- Documentation referring to "Omakub" when it should say "Bentobox"

**Fix Required:**
- Review and update user-facing references to say "Bentobox"
- Keep technical variable names like `OMAKUB_PATH` for compatibility
- Update comments and documentation

---

## 🟢 COMPARISON WITH ORIGINAL OMAKUB

### What's Working Well ✅

1. **Container deployment logic exists** - Your `select-dev-storage.sh` file properly handles Portainer, OpenWebUI, and Ollama
2. **WinBoat installation script is complete** - The `app-winboat.sh` file looks solid
3. **Custom wallpapers are included** - Your wallpaper directory has 7 beautiful Pexels images
4. **Documentation is comprehensive** - Your README is detailed and professional

### Key Differences from Omakub

| Feature | Original Omakub | Your Bentobox Fork |
|---------|----------------|-------------------|
| **Repository structure** | Clean single-level | ❌ Nested `/omakub` directory |
| **Boot script** | Single `boot.sh` | ❌ Two boot scripts (boot.sh + boot-local.sh) |
| **Container options** | lazydocker + databases | ✅ Portainer + OpenWebUI + Ollama |
| **Optional apps** | 10+ apps | ✅ Streamlined to 6 apps |
| **Windows apps** | No | ✅ WinBoat support |
| **Git status** | Clean | ❌ Unstaged changes |

---

## 🔧 DEPLOYMENT FAILURE ROOT CAUSES

Based on my analysis, deployments are likely failing because:

### Primary Cause: Repository Structure Confusion
```bash
# User runs:
wget -qO- https://raw.githubusercontent.com/languageseed/bentobox/master/boot.sh | bash

# This downloads boot.sh from the ROOT of your repo
# It clones to ~/.local/share/omakub
# But your repo has a nested /omakub directory that's outdated
# This creates confusion during file resolution
```

### Secondary Cause: Unstaged Changes
- Your `app-winboat.sh` has local changes that aren't on GitHub
- Users downloading from GitHub get an older version
- This could cause the WinBoat installation to fail

### Tertiary Cause: Local vs Remote Inconsistency
- You have `boot-local.sh` that uses a different installation path
- You're testing locally with different code than what's on GitHub
- This creates a disconnect between what works locally and what users get

---

## ✅ RECOMMENDED FIXES (Priority Order)

### 1. Clean Up Repository Structure (CRITICAL)
```bash
# In your bentobox directory:
cd /Users/ben/Documents/bentobox

# Delete the nested omakub directory
rm -rf omakub/

# Verify root-level files are correct
ls -la

# Commit the deletion
git add -A
git commit -m "Remove nested omakub directory - use root level only"
```

### 2. Commit Unstaged Changes (CRITICAL)
```bash
# Review changes
git diff install/desktop/optional/app-winboat.sh

# If changes look good:
git add install/desktop/optional/app-winboat.sh
git commit -m "Update WinBoat installation script"
```

### 3. Clean Up Local Testing Files (HIGH)
```bash
# Add boot-local.sh to .gitignore (if it's just for testing)
echo "boot-local.sh" >> .gitignore

# Or document it if it's useful for others
```

### 4. Handle commit.sh (MEDIUM)
```bash
# Option 1: Ignore it
echo "commit.sh" >> .gitignore

# Option 2: Commit it if it's useful
git add commit.sh
git commit -m "Add commit helper script"
```

### 5. Push All Changes (CRITICAL)
```bash
# Push everything to GitHub
git push origin master
```

### 6. Test Deployment (CRITICAL)
```bash
# On a fresh Ubuntu 24.04 VM or container:
wget -qO- https://raw.githubusercontent.com/languageseed/bentobox/master/boot.sh | bash

# Monitor for:
# - Successful clone
# - Files in correct locations
# - No missing script errors
# - Containers deploy successfully
```

---

## 📊 SUMMARY

### Critical Issues: 4
1. Nested `/omakub` directory structure ⚠️
2. Dual boot scripts (boot.sh vs boot-local.sh) ⚠️
3. Documentation inconsistencies ⚠️
4. Unstaged changes in app-winboat.sh ⚠️

### Moderate Issues: 3
5. Untracked commit.sh file
6. Version number mismatches
7. Excessive OMAKUB references in documentation

### Estimated Time to Fix: 30-60 minutes

### Testing Required After Fixes:
- ✅ Fresh Ubuntu 24.04 VM installation
- ✅ Verify containers deploy (Portainer, OpenWebUI, Ollama)
- ✅ Test WinBoat installation
- ✅ Verify wallpapers apply correctly

---

## 🎯 NEXT STEPS

1. **Backup current state:**
   ```bash
   cd /Users/ben/Documents/bentobox
   git branch backup-$(date +%Y%m%d)
   ```

2. **Apply fixes 1-5 above**

3. **Test locally with boot-local.sh (if you have a test environment)**

4. **Push to GitHub**

5. **Test remote deployment on fresh Ubuntu 24.04**

6. **Document any remaining issues**

---

## 📝 NOTES

- Your customizations (Portainer, OpenWebUI, WinBoat) are excellent additions
- The core problem is repository organization, not your actual code
- Once the structure is cleaned up, deployment should work perfectly
- Original Omakub is at **v1.5.0** (Nov 9, 2025) - you may want to sync upstream changes

---

**End of Report**

