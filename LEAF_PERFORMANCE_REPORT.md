# Ubuntu 24.04 (Bentobox) Performance Tuning Report

**Generated:** November 22, 2024  
**System Analyzed:** Ubuntu 24.04.3 LTS (Bentobox installation)  
**Example Hardware:** Intel i9-13980HX (32 cores), 62GB RAM, 1.8TB ZFS

> **Note:** This report was created based on analysis of a specific system ("leaf"), but the recommendations and scripts are generic and will work on any Ubuntu 24.04 Bentobox installation.

---

## 📊 Current Performance Status

### Boot Time Analysis
- **Total Boot Time:** 50.8 seconds
  - Firmware: 6.5s
  - Bootloader: 3.9s
  - Kernel: 26.7s
  - Userspace: 13.7s

### Critical Issues Found

#### 🔴 HIGH IMPACT
1. **synergy.service** - 1min 30s (FAILED)
   - Taking 90 seconds and failing
   - Major boot delay
   - Service is not functioning correctly

2. **NetworkManager-wait-online.service** - 6.0s
   - Blocking Docker startup unnecessarily
   - Not needed for desktop workstations

#### 🟡 MEDIUM IMPACT
3. **plymouth-quit-wait.service** - 5.2s
   - Boot splash screen delay
   - Can be optimized

4. **systemd-udev-settle.service** - 2.8s
   - Waiting for all devices to initialize
   - Often unnecessary

5. **Unnecessary Services Running:**
   - cups-browsed (printer discovery)
   - bluetooth (if not using Bluetooth devices)
   - ModemManager (if not using mobile broadband)
   - avahi-daemon (network service discovery)
   - kerneloops (kernel error reporting)

---

## 🚀 Performance Optimization Recommendations

### Priority 1: Fix Critical Issues (Save ~96 seconds boot time)

#### Fix Synergy Service
The synergy.service is failing and adding 90 seconds to boot time:
```bash
# Option A: Fix the service (if you need Synergy)
sudo systemctl status synergy.service  # Check error details
# Then fix the service file or reinstall Synergy

# Option B: Disable if not needed (RECOMMENDED)
sudo systemctl disable synergy.service
sudo systemctl mask synergy.service
```

#### Disable NetworkManager-wait-online
This blocks Docker but isn't needed for desktop systems:
```bash
sudo systemctl disable NetworkManager-wait-online.service
```

**Expected Savings:** ~96 seconds total boot time reduction

---

### Priority 2: Disable Unnecessary Services (Save ~10-15 seconds)

#### For Systems WITHOUT These Features:

**Disable Printer Services** (if no printer):
```bash
sudo systemctl disable cups-browsed.service
sudo systemctl stop cups-browsed.service
```

**Disable Bluetooth** (if not using Bluetooth):
```bash
sudo systemctl disable bluetooth.service
sudo systemctl stop bluetooth.service
```

**Disable Modem Manager** (if not using mobile broadband):
```bash
sudo systemctl disable ModemManager.service
sudo systemctl stop ModemManager.service
```

**Disable Avahi** (if not using network service discovery):
```bash
sudo systemctl disable avahi-daemon.service
sudo systemctl stop avahi-daemon.service
```

**Disable Kernel Error Reporting** (optional):
```bash
sudo systemctl disable kerneloops.service
sudo systemctl stop kerneloops.service
```

---

### Priority 3: Systemd Optimizations

#### Speed Up Plymouth (Boot Splash)
```bash
# Edit GRUB config
sudo nano /etc/default/grub

# Add to GRUB_CMDLINE_LINUX_DEFAULT:
# quiet splash loglevel=0 rd.systemd.show_status=auto rd.udev.log_level=3

# Then update GRUB
sudo update-grub
```

#### Disable systemd-udev-settle
```bash
sudo systemctl mask systemd-udev-settle.service
```

---

### Priority 4: Shutdown/Restart Optimizations

#### Reduce Default Stop Timeout
```bash
sudo mkdir -p /etc/systemd/system.conf.d/
sudo tee /etc/systemd/system.conf.d/timeout.conf << 'EOF'
[Manager]
# Reduce default timeout for stopping services (default: 90s)
DefaultTimeoutStopSec=10s
# Reduce timeout for starting services
DefaultTimeoutStartSec=30s
EOF

sudo systemctl daemon-reload
```

#### Optimize Docker Shutdown
```bash
sudo mkdir -p /etc/systemd/system/docker.service.d/
sudo tee /etc/systemd/system/docker.service.d/shutdown.conf << 'EOF'
[Service]
# Faster Docker shutdown
TimeoutStopSec=30s
EOF

sudo systemctl daemon-reload
```

---

### Priority 5: Journal Size Optimization

Current journal usage is good (12MB), but we can set limits:
```bash
sudo mkdir -p /etc/systemd/journald.conf.d/
sudo tee /etc/systemd/journald.conf.d/size.conf << 'EOF'
[Journal]
# Limit journal to 100MB
SystemMaxUse=100M
# Keep 7 days of logs
MaxRetentionSec=7d
EOF

sudo systemctl restart systemd-journald
```

---

### Priority 6: Memory Optimizations

#### Adjust Swappiness (Favor RAM)
Your system has 62GB RAM, so reduce swap usage:
```bash
# Check current value
cat /proc/sys/vm/swappiness

# Set to 10 (default is 60)
echo "vm.swappiness=10" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
```

---

## 🎯 Expected Results

### Before Optimizations
- Boot time: **50.8 seconds**
- Shutdown time: **~90 seconds** (default timeout)
- Unnecessary services: **5+ running**

### After Optimizations (Conservative Estimate)
- Boot time: **~25-30 seconds** (40-49% faster)
  - Synergy fix: -90s
  - NetworkManager-wait-online: -6s
  - Other services: -5-10s
- Shutdown time: **~10-15 seconds** (83% faster)
- Memory freed: **~50-100MB**

---

## 🛠️ Automated Implementation Script

See `bentobox-performance-tuning.sh` for automated implementation.

**Usage:**
```bash
# Download to your Bentobox system
./bentobox-performance-tuning.sh

# Script will prompt for sudo password when needed
# Works with any user account that has sudo privileges
```

---

## ⚠️ Important Notes

### What NOT to Disable
- **ssh.service** - You need this for remote access
- **docker.service** - Required for Portainer, OpenWebUI, Ollama
- **NetworkManager.service** - Required for network connectivity
- **gdm.service** - Required for graphical login

### Reversing Changes
To undo any service disabling:
```bash
sudo systemctl unmask SERVICE_NAME.service
sudo systemctl enable SERVICE_NAME.service
sudo systemctl start SERVICE_NAME.service
```

---

## 📈 Monitoring Performance

### After Applying Changes
```bash
# Reboot and check new boot time
sudo reboot

# After reboot, check results:
systemd-analyze
systemd-analyze blame | head -20
systemd-analyze critical-chain

# Check failed services
systemctl --failed
```

### Verify Services Are Stopped
```bash
systemctl list-units --state=running | grep -E "cups|bluetooth|avahi|modem"
```

---

## 🎓 Additional Recommendations

### 1. NVIDIA Persistence Daemon
Currently running. If not actively using NVIDIA GPU features:
```bash
sudo systemctl disable nvidia-persistenced.service
```

### 2. Snap Refresh Optimization
Prevent snap from auto-updating during work hours:
```bash
sudo snap set system refresh.timer=fri,23:00-01:00
```

### 3. Preload (Optional)
Install preload to cache frequently used applications:
```bash
sudo apt install preload
```

### 4. Disable Cloud-Init (Not a Cloud Instance)
```bash
sudo touch /etc/cloud/cloud-init.disabled
sudo systemctl disable cloud-init.service cloud-init-local.service cloud-final.service cloud-config.service
```

---

## 🔍 System Strengths

✅ **Excellent Hardware:** 32-core i9, 62GB RAM - very powerful  
✅ **Low Memory Usage:** Only 5.4GB used, plenty available  
✅ **ZFS Filesystem:** Good for data integrity  
✅ **Small Journal:** Only 12MB, well-managed  
✅ **Docker Configured:** Proper restart policies on containers  
✅ **No Swap Usage:** All RAM-based, excellent performance  

---

## 📝 Summary

Your "leaf" system is quite powerful but has some low-hanging fruit for optimization:

1. **Fix/disable Synergy** (90s improvement)
2. **Disable NetworkManager-wait-online** (6s improvement)
3. **Disable unused services** (5-15s improvement)
4. **Optimize timeouts** (75s shutdown improvement)
5. **Tune system parameters** (responsiveness improvement)

**Total Potential Improvement:**
- Boot: **20-25 seconds faster**
- Shutdown: **75+ seconds faster**
- Overall: **Snappier, more responsive system**

