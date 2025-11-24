# WinBoat Windows 11 Installation Issues - Testing Findings

**Date:** November 23, 2025  
**System:** leaf (Ubuntu 24.04, ZFS, 16GB RAM, 6-core CPU)  
**WinBoat Version:** v0.8.7 (using dockur/windows container)  
**Windows Version Tested:** Windows 11

---

## 🔴 Critical Issue: Windows 11 TPM Requirements

### Problem Summary

Windows 11 installation **fails by default** in WinBoat due to TPM 2.0 requirements. The installation enters an infinite boot loop with the error:

> "The computer restarted unexpectedly or encountered an unexpected error. Windows installation cannot proceed."

### Root Cause

- Windows 11 requires TPM 2.0 (Trusted Platform Module)
- Virtual machines don't properly emulate TPM 2.0
- The dockur/windows container doesn't automatically bypass these checks
- Registry modifications are required to bypass hardware requirements

### Solution Required (Manual Intervention)

**Users must manually apply registry hacks during installation:**

1. Wait for installation error screen
2. Press **Shift + F10** to open Command Prompt
3. Type `regedit` and press Enter
4. Navigate to `HKEY_LOCAL_MACHINE\SYSTEM\Setup`
5. Create new key: `LabConfig`
6. Add three DWORD values (all set to `1`):
   - `BypassTPMCheck`
   - `BypassSecureBootCheck`
   - `BypassRAMCheck`
7. Close regedit and click OK to retry
8. Installation continues successfully

### Testing Experience

**Installation Timeline:**
- Attempt 1: Failed (boot loop, no bypass applied)
- Attempt 2: Failed (boot loop, registry bypass attempted but not correctly applied)
- Attempt 3: Success (registry bypass correctly applied)
- Total time spent: ~2+ hours
- Actual Windows install time (after bypass): ~30-40 minutes

**User Experience Rating:** ⭐ (1/5 stars)
- Requires advanced technical knowledge
- Multiple failed attempts
- Poor documentation in WinBoat
- Not suitable for average bentobox users

---

## ✅ Windows 10 Alternative

**Recommended approach:** Use Windows 10 instead of Windows 11

**Advantages:**
- ✅ No TPM requirements
- ✅ Installs cleanly without registry hacks
- ✅ Same application compatibility for testing
- ✅ Better VM compatibility
- ✅ Suitable for bentobox users

**Note:** Windows 10 ISO was downloaded (5.8GB) as backup but not used after Windows 11 eventually succeeded.

---

## 📊 Technical Details

### Prerequisites Fixed During Testing

**Issues Encountered and Resolved:**

1. **libfuse2 Missing** (AppImage requirement)
   - Error: `dlopen(): error loading libfuse.so.2`
   - Solution: `sudo apt-get install libfuse2t64`
   - Status: ✅ Fixed

2. **FreeRDP 3.x Missing** (RDP client)
   - Error: `xfreerdp3: command not found`
   - Solution: `sudo apt-get install freerdp3-x11`
   - Status: ✅ Fixed (v3.5.1 installed)

3. **Desktop Entry Sandbox Issue**
   - Error: Sandbox not configured correctly
   - Solution: Added `--no-sandbox` flag to `.desktop` file
   - Status: ✅ Fixed

4. **libvirt Service Inactive**
   - Solution: `sudo systemctl start libvirtd && sudo systemctl enable libvirtd`
   - Status: ✅ Fixed

### Final Prerequisites Status

All prerequisites successfully installed:

| Component | Version | Status |
|-----------|---------|--------|
| QEMU/KVM | v8.2.2 | ✅ Working |
| libvirt | Active | ✅ Working |
| Docker | Active | ✅ Working |
| virt-manager | Installed | ✅ Working |
| FreeRDP 3.x | v3.5.1 | ✅ Working |
| libfuse2 | Installed | ✅ Working |
| User Groups | docker, kvm, libvirt | ✅ Configured |

---

## 🎯 Recommendations for WinBoat

### Short-Term Improvements

1. **Default to Windows 10**
   - More reliable installation
   - Better user experience
   - Fewer support issues

2. **Add TPM Bypass Documentation**
   - Clear warning about Windows 11 issues
   - Step-by-step registry bypass guide
   - Screenshots of the process

3. **Improve Error Messages**
   - Detect Windows 11 TPM errors
   - Show bypass instructions automatically
   - Link to troubleshooting guide

### Long-Term Improvements

1. **Automatic TPM Bypass**
   - Pre-configure Windows 11 images with registry bypasses
   - Auto-inject bypass during installation
   - Remove need for manual intervention

2. **Better Windows 11 Support**
   - Improve TPM emulation in container
   - Work with dockur/windows project on fixes
   - Test with newer QEMU versions

3. **Installation Wizard Improvements**
   - Recommend Windows 10 by default
   - Warn about Windows 11 complexity
   - Offer "Easy Mode" (Win10) vs "Advanced" (Win11)

---

## 📝 Recommendations for Bentobox Integration

### If Including WinBoat:

**Installation Script Should:**
- ✅ Install all prerequisites (QEMU, libvirt, Docker, FreeRDP, libfuse2)
- ✅ Configure user groups correctly
- ✅ Create launcher scripts
- ✅ **Default to Windows 10** or warn about Windows 11

**User Documentation Should Include:**
- ⚠️ Warning: Windows 11 requires manual registry hacks
- ✅ Recommendation: Use Windows 10 for easier setup
- 📖 Troubleshooting guide with Windows 11 TPM bypass steps
- 🎯 Clear hardware requirements (16GB RAM recommended)

**Classification:**
- **Difficulty Level:** Advanced
- **User Audience:** Power users comfortable with troubleshooting
- **Recommended Label:** "BETA - Advanced Users Only"

### Alternative Recommendation:

**Consider waiting for WinBoat maturity:**
- Current version (v0.8.7) has significant installation issues
- Windows 11 support is problematic
- Better to wait for v1.0 or when TPM bypass is automatic
- Re-evaluate in 6-12 months when more stable

---

## 🧪 Next Steps: Feature Testing

Now that Windows 11 is installed, testing can proceed with:

1. **Filesystem Integration** (Priority 1)
   - Test Linux home directory mounting
   - File access from Windows apps
   - Bidirectional file changes

2. **Performance Testing** (Priority 1)
   - RDP latency measurement
   - Application responsiveness
   - Resource usage monitoring

3. **Application Compatibility** (Priority 2)
   - Install web browser
   - Test Office apps
   - Try professional software

4. **Integration Features** (Priority 2)
   - Clipboard sharing
   - Window management
   - USB passthrough (if available)

5. **Stability Testing** (Priority 3)
   - Extended uptime
   - Restart cycles
   - Error recovery

---

## 💭 Personal Assessment

**Installation Experience:** Poor (1/5 stars)
- Too complex for average users
- Multiple failures before success
- Requires deep technical knowledge
- Time-consuming troubleshooting

**Would Bentobox Users Succeed?** Unlikely
- Registry editing is too advanced
- Multiple installation attempts needed
- Poor error messaging
- No clear documentation

**Recommendation:** If including WinBoat, **strongly recommend Windows 10** and clearly label Windows 11 as "Expert Mode" with detailed warnings.

---

**Status:** Installation complete, ready for feature testing  
**Time Investment:** ~2+ hours on installation alone  
**Success Rate:** 33% (1 success out of 3 attempts)

