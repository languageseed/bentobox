#!/bin/bash

# Leaf Performance Tuning Undo Script
# Reverses all optimizations made by leaf-performance-tuning.sh

set -e

echo "=========================================="
echo "  Leaf Performance Tuning - UNDO Script"
echo "=========================================="
echo ""
echo "This will reverse all performance optimizations."
echo ""
echo "⚠️  Press Ctrl+C to cancel, or Enter to continue..."
read -r

LOG_FILE="/tmp/leaf-performance-undo-$(date +%Y%m%d-%H%M%S).log"
exec > >(tee -a "$LOG_FILE") 2>&1

echo ""
echo "=== Re-enabling services ==="
echo ""

# Function to safely re-enable a service
enable_service() {
    local service=$1
    local description=$2
    
    echo "   Re-enabling $service..."
    sudo systemctl unmask "$service" 2>/dev/null || true
    sudo systemctl enable "$service" 2>/dev/null || true
    sudo systemctl start "$service" 2>/dev/null || true
    echo "   ✅ $service re-enabled"
}

# Re-enable Synergy
echo "1. Re-enabling Synergy service..."
enable_service "synergy.service" "Synergy KVM"

# Re-enable NetworkManager-wait-online
echo ""
echo "2. Re-enabling NetworkManager-wait-online..."
enable_service "NetworkManager-wait-online.service" "Network wait"

# Re-enable printer services
echo ""
echo "3. Re-enabling printer services..."
enable_service "cups-browsed.service" "printer discovery"

# Re-enable Bluetooth
echo ""
echo "4. Re-enabling Bluetooth..."
enable_service "bluetooth.service" "Bluetooth support"

# Re-enable ModemManager
echo ""
echo "5. Re-enabling ModemManager..."
enable_service "ModemManager.service" "mobile broadband"

# Re-enable Avahi
echo ""
echo "6. Re-enabling Avahi daemon..."
enable_service "avahi-daemon.service" "network service discovery"

# Re-enable kernel error reporting
echo ""
echo "7. Re-enabling kernel error reporting..."
enable_service "kerneloops.service" "kernel crash reporting"

# Unmask systemd-udev-settle
echo ""
echo "8. Unmasking systemd-udev-settle..."
sudo systemctl unmask systemd-udev-settle.service 2>/dev/null || true
echo "   ✅ systemd-udev-settle unmasked"

# Re-enable cloud-init services
echo ""
echo "9. Re-enabling cloud-init services..."
if [ -f /etc/cloud/cloud-init.disabled ]; then
    sudo rm /etc/cloud/cloud-init.disabled
    enable_service "cloud-init.service" "cloud initialization"
    enable_service "cloud-init-local.service" "cloud initialization (local)"
    enable_service "cloud-config.service" "cloud configuration"
    enable_service "cloud-final.service" "cloud finalization"
    echo "   ✅ Cloud-init re-enabled"
fi

echo ""
echo "=== Removing custom configurations ==="
echo ""

# Remove custom timeout config
echo "10. Removing custom timeout configuration..."
if [ -f /etc/systemd/system.conf.d/timeout.conf ]; then
    sudo rm /etc/systemd/system.conf.d/timeout.conf
    echo "   ✅ Default timeouts restored (90s)"
fi

# Remove Docker shutdown optimization
echo ""
echo "11. Removing Docker shutdown optimization..."
if [ -f /etc/systemd/system/docker.service.d/shutdown.conf ]; then
    sudo rm /etc/systemd/system/docker.service.d/shutdown.conf
    echo "   ✅ Docker default timeout restored"
fi

# Remove journal size limits
echo ""
echo "12. Removing journal size limits..."
if [ -f /etc/systemd/journald.conf.d/size.conf ]; then
    sudo rm /etc/systemd/journald.conf.d/size.conf
    echo "   ✅ Journal limits removed (using defaults)"
fi

# Restore default swappiness
echo ""
echo "13. Restoring default swappiness..."
if grep -q "vm.swappiness" /etc/sysctl.conf; then
    sudo sed -i '/vm.swappiness/d' /etc/sysctl.conf
    sudo sysctl -w vm.swappiness=60
    echo "   ✅ Swappiness restored to 60 (default)"
fi

# Restore default snap refresh schedule
echo ""
echo "14. Restoring default snap refresh schedule..."
sudo snap unset system refresh.timer
echo "   ✅ Snap updates on default schedule"

echo ""
echo "=== Reloading systemd configuration ==="
echo ""
sudo systemctl daemon-reload
sudo systemctl restart systemd-journald
echo "   ✅ Systemd configuration reloaded"

echo ""
echo "=========================================="
echo "  ✅ UNDO COMPLETE!"
echo "=========================================="
echo ""
echo "All optimizations have been reversed."
echo "System is back to default Ubuntu configuration."
echo ""
echo "📝 Log saved to: $LOG_FILE"
echo ""
echo "⚠️  REBOOT REQUIRED for full effect"
echo ""
echo "To reboot now: sudo reboot"
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

