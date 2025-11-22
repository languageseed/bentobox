# Security Advisory - November 22, 2024

## Issue: Hardcoded Credentials in Performance Scripts

### Summary
The initial version of the performance tuning scripts (`leaf-performance-tuning.sh` and `leaf-performance-tuning-undo.sh`) contained hardcoded credentials that were specific to a single test system. This has been corrected.

### Affected Versions
- Commit `9943aee` and earlier (November 22, 2024)
- Files: `leaf-performance-tuning.sh`, `leaf-performance-tuning-undo.sh`

### Issue Details
The scripts contained:
- Hardcoded username: `labadmin`
- Hardcoded password in sudo commands
- System-specific naming ("leaf")

### Security Impact
**LOW** - The scripts were development/testing scripts for a specific system and were not part of the main Bentobox installation process. However, publishing hardcoded credentials to a public repository is bad practice.

### Resolution
**Fixed in commit `9486b2b`** (November 22, 2024)

Changes made:
1. ✅ Removed all hardcoded usernames
2. ✅ Removed all hardcoded passwords
3. ✅ Scripts now use standard `sudo` prompts
4. ✅ Renamed to generic names: `bentobox-performance-tuning.sh`
5. ✅ Added root user detection and warning
6. ✅ Added current user detection (`$USER` variable)
7. ✅ Updated all documentation

### Action Required
**If you downloaded the old scripts:**
1. Delete the old scripts: `leaf-performance-tuning.sh`, `leaf-performance-tuning-undo.sh`
2. Download the new versions: `bentobox-performance-tuning.sh`, `bentobox-performance-tuning-undo.sh`
3. The new scripts will prompt for your password securely

**If you cloned the repository:**
```bash
cd bentobox
git pull
# Old scripts are automatically removed by git
# New scripts are now in place
```

### New Script Usage
The corrected scripts are now fully portable and secure:

```bash
# Run as your regular user (NOT with sudo)
./bentobox-performance-tuning.sh

# You'll be prompted for your password when needed
# Works with ANY username that has sudo privileges
```

### Best Practices Applied
- ✅ No hardcoded credentials
- ✅ Standard sudo password prompts
- ✅ User-agnostic design
- ✅ Portable across any installation
- ✅ Proper error handling
- ✅ Security checks (prevents running as root)

### Timeline
- **20:21 AWST Nov 22, 2024** - Initial scripts created with hardcoded credentials
- **20:35 AWST Nov 22, 2024** - Issue identified by user
- **20:40 AWST Nov 22, 2024** - Fixed and pushed to repository
- **Duration:** ~19 minutes from creation to fix

### Lessons Learned
1. Never hardcode credentials, even in test/development scripts
2. Always use standard authentication mechanisms (sudo prompts)
3. Design scripts to be portable from the start
4. Test scripts with different usernames before publishing

### Contact
If you have questions or concerns about this security fix, please open an issue on the GitHub repository.

---

**Repository:** https://github.com/languageseed/bentobox  
**Fixed Commit:** `9486b2b`  
**Status:** ✅ RESOLVED

