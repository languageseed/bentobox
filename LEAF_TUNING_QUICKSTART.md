# Leaf Performance Tuning - Quick Start Guide

## 📊 Current Performance
- **Boot Time:** 50.8 seconds
- **Shutdown Time:** ~90 seconds (default timeout)
- **Main Issues:**
  - Synergy service: 90 seconds (FAILING)
  - NetworkManager-wait-online: 6 seconds (unnecessary)
  - Several unused services running

## 🚀 Expected Improvements
- **Boot Time:** ~25-30 seconds (40-49% faster)
- **Shutdown Time:** ~10-15 seconds (83% faster)
- **Memory:** ~50-100MB freed
- **Overall:** Snappier, more responsive

## 📋 Files on Leaf Server
Three files have been copied to `/home/labadmin/`:

1. **LEAF_PERFORMANCE_REPORT.md** - Detailed analysis and recommendations
2. **leaf-performance-tuning.sh** - Automated optimization script
3. **leaf-performance-tuning-undo.sh** - Script to reverse all changes

## ⚡ Quick Implementation

### Option 1: Automated (Recommended)
```bash
ssh leaf
cd ~
./leaf-performance-tuning.sh
# Review changes, press Enter to apply
# Reboot when prompted
```

### Option 2: Manual (Pick & Choose)
Read `LEAF_PERFORMANCE_REPORT.md` and apply only the optimizations you want.

## 🎯 What Gets Optimized

### Critical Fixes (96s saved)
- ✅ Fix/disable failing Synergy service (-90s)
- ✅ Disable NetworkManager-wait-online (-6s)

### Service Cleanup (5-15s saved)
- ✅ Disable cups-browsed (if no printer)
- ✅ Disable bluetooth (if not using Bluetooth)
- ✅ Disable ModemManager (if no mobile broadband)
- ✅ Disable avahi-daemon (network discovery)
- ✅ Disable kerneloops (error reporting)
- ✅ Mask systemd-udev-settle

### Timeout Optimizations (75s shutdown)
- ✅ DefaultTimeoutStopSec: 10s (was 90s)
- ✅ DefaultTimeoutStartSec: 30s (was 90s)
- ✅ Docker shutdown: 30s

### System Tuning
- ✅ Journal size limit: 100MB
- ✅ Swappiness: 10 (favor RAM)
- ✅ Disable cloud-init
- ✅ Snap updates: Friday 11PM

## ⚠️ Important Notes

### Safe Services (NOT touched)
- ssh.service (remote access)
- docker.service (containers)
- NetworkManager.service (networking)
- gdm.service (graphical login)

### Reverting Changes
If you need to undo everything:
```bash
ssh leaf
cd ~
./leaf-performance-tuning-undo.sh
```

## 📈 Verify Results

After reboot:
```bash
# Check boot time
systemd-analyze

# Check slow services
systemd-analyze blame | head -20

# Check critical path
systemd-analyze critical-chain

# Check failed services
systemctl --failed

# Verify services stopped
systemctl list-units --state=running | grep -E "cups|bluetooth|avahi|modem"
```

## 🎓 Additional Manual Optimizations

### If you don't use NVIDIA GPU features:
```bash
sudo systemctl disable nvidia-persistenced.service
```

### Install preload (caches frequently used apps):
```bash
sudo apt install preload
```

### GRUB optimization (quieter boot):
```bash
sudo nano /etc/default/grub
# Add: quiet splash loglevel=0 rd.systemd.show_status=auto rd.udev.log_level=3
sudo update-grub
```

## 📞 Support

Questions about specific optimizations? Check `LEAF_PERFORMANCE_REPORT.md` for detailed explanations.

---

**Ready to optimize? SSH to leaf and run the script!**

```bash
ssh leaf
./leaf-performance-tuning.sh
```

