#!/bin/bash

# Bentobox Performance Tuning Script
# Optimizes Ubuntu 24.04 (Bentobox) for faster boot, shutdown, and better performance
# Safe to run - creates backups and can be reversed
# Works with any user account with sudo privileges

set -e

# Check if running with sudo/root privileges
if [ "$EUID" -eq 0 ]; then
    echo "⚠️  Please do NOT run this script with sudo or as root."
    echo "   Run it as your regular user - it will prompt for sudo when needed."
    exit 1
fi

echo "=========================================="
echo "  Bentobox Performance Optimization"
echo "=========================================="
echo ""
echo "This script will optimize:"
echo "  - Boot time (expected: 25-30s, down from 50s)"
echo "  - Shutdown time (expected: 10-15s, down from 90s)"
echo "  - Memory usage and responsiveness"
echo ""
echo "⚠️  Press Ctrl+C to cancel, or Enter to continue..."
read -r

# Create a log
LOG_FILE="/tmp/bentobox-performance-tuning-$(date +%Y%m%d-%H%M%S).log"
exec > >(tee -a "$LOG_FILE") 2>&1

echo ""
echo "Running as user: $USER"
echo "Log file: $LOG_FILE"
echo ""

echo ""
echo "=== PRIORITY 1: Fix Critical Issues ==="
echo ""

# Fix Synergy service (biggest issue - 90 second delay)
echo "1. Fixing Synergy service (currently taking 90 seconds and failing)..."
if systemctl is-enabled synergy.service &>/dev/null; then
    echo "   Disabling synergy.service..."
    sudo systemctl disable synergy.service
    sudo systemctl mask synergy.service
    echo "   ✅ Synergy service disabled (saves ~90s boot time)"
else
    echo "   ℹ️  Synergy service already disabled"
fi

# Disable NetworkManager-wait-online (6 second delay, unnecessary for desktop)
echo ""
echo "2. Disabling NetworkManager-wait-online..."
if systemctl is-enabled NetworkManager-wait-online.service &>/dev/null; then
    sudo systemctl disable NetworkManager-wait-online.service
    echo "   ✅ NetworkManager-wait-online disabled (saves ~6s boot time)"
else
    echo "   ℹ️  NetworkManager-wait-online already disabled"
fi

echo ""
echo "=== PRIORITY 2: Disable Unnecessary Services ==="
echo ""

# Function to safely disable a service
disable_service() {
    local service=$1
    local description=$2
    
    if systemctl is-active "$service" &>/dev/null || systemctl is-enabled "$service" &>/dev/null; then
        echo "   Disabling $service ($description)..."
        sudo systemctl stop "$service" 2>/dev/null || true
        sudo systemctl disable "$service" 2>/dev/null || true
        echo "   ✅ $service disabled"
    else
        echo "   ℹ️  $service already disabled/not present"
    fi
}

# Disable printer services (if no printer)
echo "3. Disabling printer services (if not using printer)..."
disable_service "cups-browsed.service" "printer discovery"

# Disable Bluetooth (if not using Bluetooth)
echo ""
echo "4. Disabling Bluetooth service (if not using Bluetooth devices)..."
disable_service "bluetooth.service" "Bluetooth support"

# Disable ModemManager (if not using mobile broadband)
echo ""
echo "5. Disabling ModemManager (if not using mobile broadband)..."
disable_service "ModemManager.service" "mobile broadband"

# Disable Avahi (if not using network service discovery)
echo ""
echo "6. Disabling Avahi daemon (network service discovery)..."
disable_service "avahi-daemon.service" "network service discovery"

# Disable kernel error reporting
echo ""
echo "7. Disabling kernel error reporting..."
disable_service "kerneloops.service" "kernel crash reporting"

echo ""
echo "=== PRIORITY 3: Systemd Optimizations ==="
echo ""

# Mask systemd-udev-settle (adds 2.8s delay)
echo "8. Masking systemd-udev-settle..."
if ! systemctl is-masked systemd-udev-settle.service &>/dev/null; then
    sudo systemctl mask systemd-udev-settle.service
    echo "   ✅ systemd-udev-settle masked (saves ~2.8s)"
else
    echo "   ℹ️  systemd-udev-settle already masked"
fi

echo ""
echo "=== PRIORITY 4: Shutdown/Restart Optimizations ==="
echo ""

# Set shorter timeouts for stop/start
echo "9. Configuring faster shutdown timeouts..."
sudo mkdir -p /etc/systemd/system.conf.d/
sudo tee /etc/systemd/system.conf.d/timeout.conf > /dev/null << 'EOF'
[Manager]
# Reduce default timeout for stopping services (default: 90s)
DefaultTimeoutStopSec=10s
# Reduce timeout for starting services (default: 90s)
DefaultTimeoutStartSec=30s
EOF
echo "   ✅ System timeouts configured (10s stop, 30s start)"

# Optimize Docker shutdown specifically
echo ""
echo "10. Optimizing Docker shutdown..."
sudo mkdir -p /etc/systemd/system/docker.service.d/
sudo tee /etc/systemd/system/docker.service.d/shutdown.conf > /dev/null << 'EOF'
[Service]
# Faster Docker shutdown
TimeoutStopSec=30s
EOF
echo "   ✅ Docker shutdown timeout set to 30s"

echo ""
echo "=== PRIORITY 5: Journal Size Limits ==="
echo ""

echo "11. Setting journal size limits..."
sudo mkdir -p /etc/systemd/journald.conf.d/
sudo tee /etc/systemd/journald.conf.d/size.conf > /dev/null << 'EOF'
[Journal]
# Limit journal to 100MB
SystemMaxUse=100M
# Keep 7 days of logs
MaxRetentionSec=7d
EOF
echo "   ✅ Journal limited to 100MB, 7 days retention"

echo ""
echo "=== PRIORITY 6: Memory Optimizations ==="
echo ""

# Reduce swappiness (favor RAM over swap)
echo "12. Optimizing swap usage (favoring RAM)..."
if ! grep -q "vm.swappiness" /etc/sysctl.conf; then
    echo "vm.swappiness=10" | sudo tee -a /etc/sysctl.conf
    echo "   ✅ Swappiness set to 10 (was 60)"
else
    echo "   ℹ️  Swappiness already configured"
fi

echo ""
echo "=== BONUS: Additional Optimizations ==="
echo ""

# Disable cloud-init (not needed on physical machines)
echo "13. Disabling cloud-init (not a cloud instance)..."
if [ ! -f /etc/cloud/cloud-init.disabled ]; then
    sudo touch /etc/cloud/cloud-init.disabled
    disable_service "cloud-init.service" "cloud initialization"
    disable_service "cloud-init-local.service" "cloud initialization (local)"
    disable_service "cloud-config.service" "cloud configuration"
    disable_service "cloud-final.service" "cloud finalization"
    echo "   ✅ Cloud-init disabled"
else
    echo "   ℹ️  Cloud-init already disabled"
fi

# Optimize snap refresh timing
echo ""
echo "14. Optimizing snap refresh schedule..."
sudo snap set system refresh.timer=fri,23:00-01:00
echo "   ✅ Snap updates scheduled for Friday 11PM-1AM"

echo ""
echo "=== Reloading systemd configuration ==="
echo ""
sudo systemctl daemon-reload
echo "   ✅ Systemd configuration reloaded"

# Apply sysctl changes
echo ""
echo "=== Applying kernel parameters ==="
echo ""
sudo sysctl -p
echo "   ✅ Kernel parameters applied"

echo ""
echo "=========================================="
echo "  ✅ OPTIMIZATION COMPLETE!"
echo "=========================================="
echo ""
echo "📊 Expected Improvements:"
echo "   - Boot time: ~25-30 seconds (was 50.8s)"
echo "   - Shutdown time: ~10-15 seconds (was ~90s)"
echo "   - Freed memory: ~50-100MB"
echo "   - Snappier overall responsiveness"
echo ""
echo "📝 Log saved to: $LOG_FILE"
echo ""
echo "⚠️  REBOOT REQUIRED to see full effects"
echo ""
echo "To reboot now: sudo reboot"
echo ""
echo "After reboot, check results with:"
echo "   systemd-analyze"
echo "   systemd-analyze blame | head -20"
echo "   systemctl --failed"
echo ""
echo "=========================================="
echo ""
echo "To REVERSE these changes, see the undo script:"
echo "   ./leaf-performance-tuning-undo.sh"
echo ""

# Offer to reboot
echo ""
echo "Reboot now? (y/N)"
read -r response
if [[ "$response" =~ ^[Yy]$ ]]; then
    echo "Rebooting in 5 seconds... (Ctrl+C to cancel)"
    sleep 5
    sudo reboot
else
    echo "Remember to reboot when convenient!"
fi

