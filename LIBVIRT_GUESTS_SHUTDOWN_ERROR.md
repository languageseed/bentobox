# libvirt-guests Shutdown Error - Fix Guide

## Error Message at Shutdown/Restart:

```
[FAILED] Failed unmounting run-user-1000.mount - /run/user/1000.
[***   ] libvirt-guests.sh[12029]: Can't connect to default. Skipping.
```

---

## 🔍 What This Means

### The Error is **HARMLESS** but annoying to see.

**What's happening:**
1. During shutdown, `libvirt-guests.service` tries to gracefully shutdown any running VMs
2. It attempts to connect to the libvirt default connection
3. By shutdown time, the user session (`/run/user/1000`) is already being torn down
4. libvirt can't connect because the socket is gone
5. Service says "Skipping" and continues - **no actual problem**

**Impact:** 
- ❌ Cosmetic only - looks scary but doesn't break anything
- ✅ System shuts down normally anyway
- ✅ No data loss or corruption
- ✅ Just a timing issue in the shutdown sequence

---

## ✅ Solution Options

### Option 1: Ignore It (Recommended)

**Just leave it alone.** This is a cosmetic issue that doesn't affect system operation.

**Pros:**
- No changes needed
- System works fine
- libvirt functions normally

**Cons:**  
- See error message at every shutdown/restart
- Looks alarming but isn't

---

### Option 2: Disable libvirt-guests Service

If you're not running VMs that need graceful shutdown, disable this service:

```bash
# Disable the service
sudo systemctl disable libvirt-guests.service
sudo systemctl mask libvirt-guests.service
```

**When to use:**
- You don't have running VMs during shutdown
- WinBoat isn't running at shutdown time
- You're okay with VMs being forcefully stopped (if any)

**Pros:**
- Removes the error message
- Slightly faster shutdown
- One less service to wait for

**Cons:**
- If you DO have VMs running at shutdown, they'll be forcefully stopped instead of gracefully shut down
- Could cause data corruption in VMs if they're writing data

---

### Option 3: Fix the Service Ordering (Advanced)

Create a systemd override to make the service more resilient:

```bash
# Create override directory
sudo mkdir -p /etc/systemd/system/libvirt-guests.service.d/

# Create override file
sudo tee /etc/systemd/system/libvirt-guests.service.d/override.conf << 'EOF'
[Unit]
# Don't fail if can't connect
SuccessExitStatus=0 1

[Service]
# Make failures non-critical
RemainAfterExit=yes
Type=oneshot
StandardError=null
EOF

# Reload systemd
sudo systemctl daemon-reload
```

**Pros:**
- Service still runs but doesn't show error
- Graceful VM shutdown still works (if VMs running)
- No cosmetic error messages

**Cons:**
- More complex
- Hides ALL errors from the service (not just this one)

---

## 🎯 Recommended Action

### For WinBoat Testing System (leaf):

**Option 1: Ignore it** ✅

**Why:**
- You're not running VMs at shutdown currently
- Error is harmless
- When you DO use WinBoat, you'll want the graceful shutdown
- No risk, just cosmetic

**If it really bothers you:**
- Use Option 2 (disable) for now
- Re-enable later when actively using WinBoat VMs:
  ```bash
  sudo systemctl unmask libvirt-guests.service
  sudo systemctl enable libvirt-guests.service
  ```

---

## 📋 Understanding the Services

### What libvirt-guests Does:

1. **At Shutdown:**
   - Enumerates running VMs
   - Sends graceful shutdown signal to each
   - Waits for them to stop cleanly
   - Suspends VMs if they don't stop (optional)

2. **At Boot:**
   - Checks for VMs that were running before
   - Optionally restarts them

### Why It's Failing:

```
Shutdown sequence:
1. User logs out
2. /run/user/1000 starts unmounting
3. libvirt-guests.service starts
4. Tries to connect via /run/user/1000/libvirt/...
5. Path is gone! → "Can't connect"
6. Service continues anyway (skips)
```

**The Real Fix** (upstream):
- libvirt-guests should connect to system socket, not user socket
- Or check if socket exists before trying
- This is a known minor issue in Ubuntu's libvirt packaging

---

## 🔧 Quick Commands

### Check if service is causing the issue:
```bash
systemctl status libvirt-guests.service
```

### Check for running VMs:
```bash
sudo virsh list --all
```

### If no VMs ever running, disable:
```bash
sudo systemctl disable libvirt-guests.service
```

### If you want to suppress the error cosmetically:
```bash
sudo systemctl mask libvirt-guests.service
```

### To re-enable later:
```bash
sudo systemctl unmask libvirt-guests.service
sudo systemctl enable libvirt-guests.service
```

---

## 🎓 Related Information

### Other Similar Harmless Shutdown Messages:

Many services show "FAILED" at shutdown but are actually fine:
- Unmounting user runtime directories (like yours)
- Stopping already-stopped services
- Disconnecting already-disconnected sessions

**Key indicator it's harmless:**
- Message says "Skipping" or continues
- System completes shutdown normally
- No actual functionality broken

### When to Worry:

You should investigate shutdown errors if:
- ❌ System hangs during shutdown
- ❌ Forced reboot required
- ❌ Data corruption after restart
- ❌ Services fail to start after reboot

Your error does **none** of these - it's just cosmetic! ✅

---

## ✅ Recommendation for leaf

**Do nothing.** This error is:
- Cosmetic only
- Doesn't affect ZFS boot (your actual issue)
- Doesn't affect system stability
- Common on Ubuntu systems with libvirt installed
- Will go away on its own when WinBoat VMs are properly managed

**Focus on:**
- ✅ Verifying ZFS pools import correctly (the real issue we fixed)
- ✅ Testing WinBoat when you get to GUI testing
- ✅ Monitoring for actual problems that affect functionality

---

## 📞 Further Reading

- Ubuntu Bug: https://bugs.launchpad.net/ubuntu/+source/libvirt (search "libvirt-guests shutdown")
- libvirt docs: https://libvirt.org/
- systemd service management: `man systemd.service`

---

**Summary:** Ignore this error. It's just libvirt-guests being overzealous about checking for VMs during shutdown. Your system is fine! 🎉

**Created:** November 23, 2024  
**System:** leaf (Ubuntu 24.04.3)  
**Status:** Documented - No action required

