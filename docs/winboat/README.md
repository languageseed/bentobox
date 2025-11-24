# WinBoat Testing & Evaluation

## Overview

**WinBoat** is an open-source tool that enables running Windows applications on Linux with seamless desktop integration. It uses virtualization (QEMU) with Docker containerization and RDP display streaming to provide a native-like Windows experience within Linux.

**Think of it as "Reverse WSL"** - Just like WSL (Windows Subsystem for Linux) lets Windows users run Linux apps seamlessly, WinBoat lets Linux users run Windows apps seamlessly, with GUI windows appearing natively on the Linux desktop.

**Official Website:** https://www.winboat.app/  
**License:** MIT  
**Status:** Beta (as of November 2024)

## Key Features

### ✨ Core Capabilities
- **Seamless Integration**: Windows apps appear as native Linux windows
- **Automated Windows Installation**: GUI-driven setup, no manual configuration
- **Full Application Support**: Runs any Windows application
- **Filesystem Integration**: Linux home directory mounted in Windows
- **USB Passthrough**: Experimental support for USB device passthrough (v0.8.0+)
- **Resource Monitoring**: Built-in monitoring tools
- **Smartcard Passthrough**: Additional hardware integration

### 🎯 Use Cases
- Running Windows-only productivity tools (Office 365, Adobe Suite, Affinity Photo)
- Professional applications that don't work well with WINE/CrossOver
- Development tools requiring Windows environment
- Legacy Windows applications
- Peripheral configuration software (via USB passthrough)

## Technical Architecture

### Components
- **Hypervisor**: QEMU/KVM
- **VM Management**: libvirt + virt-manager (GUI)
- **Container Platform**: Docker (Podman support planned)
- **Display Protocol**: RDP (Looking Glass planned for future)
- **Storage**: Docker volumes with Linux filesystem mounting
- **Networking**: Bridged/NAT networking

### System Requirements
- **OS**: Ubuntu 24.04+ (any modern Linux with KVM support)
- **CPU**: x86_64 with virtualization support (Intel VT-x / AMD-V)
- **RAM**: Minimum 8GB recommended (4GB for VM + host system)
- **Storage**: 40GB+ free space (for Windows VM)
- **GPU**: Not required (no GPU passthrough yet)

### Pre-requisites
```bash
# KVM/QEMU virtualization stack
sudo apt install qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils

# Virtual Machine Manager (GUI for managing VMs)
sudo apt install virt-manager

# Docker (for WinBoat containerization)
sudo apt install docker.io docker-compose

# Virtualization must be enabled in BIOS/UEFI
```

## Comparison with Alternatives

### vs. WSL (Windows Subsystem for Linux)
- **Conceptual Parallel**: WinBoat is essentially "Reverse WSL"
- **WSL**: Windows host → runs Linux apps
- **WinBoat**: Linux host → runs Windows apps
- **Both**: Seamless GUI integration, filesystem sharing, clipboard integration

### vs. WinApps
- **WinBoat**: Complete GUI interface, automated setup, cohesive experience
- **WinApps**: Manual setup, TUI + CLI commands, configuration files

### vs. WINE/CrossOver
- **WinBoat**: Full Windows environment, better compatibility for complex apps
- **WINE/CrossOver**: Lighter weight, but limited compatibility
- **WinBoat works for**: Adobe Suite, Affinity Photo, Office 365, Paint Tool Sai, AeroChat, Acrobat

### vs. Dual Boot
- **WinBoat**: No reboot required, seamless integration, file sharing
- **Dual Boot**: Better performance, full hardware access

### vs. Manual QEMU/KVM + virt-manager
- **WinBoat**: Automated setup, seamless window integration, one-click install
- **Manual KVM**: Full control, but requires significant configuration expertise
- **Note**: WinBoat uses libvirt/virt-manager under the hood, accessible for advanced users

## Limitations & Considerations

### ❌ Current Limitations
- **No GPU Acceleration**: Paravirtualized drivers planned for future
- **No Anti-Cheat Games**: Kernel anti-cheat blocks virtualization
- **Beta Software**: Expect bugs and hiccups
- **RDP Performance**: Not suitable for high-performance gaming
- **Resource Usage**: VM requires significant RAM/CPU

### ⚠️ Beta Status Warning
> WinBoat is currently in Beta. Users should be comfortable with troubleshooting.
> Current iteration is not representative of final product.

## Installation Methods

### Available Formats
1. **AppImage** - Universal, no installation required
2. **Debian** (.deb) - For Ubuntu/Debian systems
3. **Fedora** (.rpm) - For Fedora/RHEL systems
4. **Arch** - AUR package

### Download Links
- Official: https://www.winboat.app/#download
- GitHub: https://github.com/winboat (check for official repo)

## Testing Plan

See `TESTING_PLAN.md` for detailed testing procedures.

## Deployment Strategy

See `DEPLOYMENT_NOTES.md` for bentobox integration considerations.

## Resources

- **Website**: https://www.winboat.app/
- **Documentation**: Check official website FAQ section
- **Community**: Discord server (link on website)
- **Contributions**: MIT license, accepts community contributions
- **Donations**: Ko-fi, Monero (XMR)

## Sponsors

- **Firstheberg**: Provides hosting infrastructure for CI/CD, testing VMs

## Future Roadmap

### Planned Features
- GPU acceleration via paravirtualized drivers
- Looking Glass integration (high-performance display streaming)
- Podman support as Docker alternative
- Flatpak distribution
- DirectX driver support (in development by community)

### Under Investigation
- MVisor Win VGPU Driver for OpenGL (requires porting to QEMU)
- Looking Glass Indirect Display Driver (not ready yet)

## Decision Criteria for Bentobox

### ✅ Pros for Inclusion
- Fills gap for Windows-only apps that don't work with WINE
- Open source (MIT) - aligns with bentobox philosophy
- Active development and community
- Professional use cases (Adobe, Office, development tools)
- Modern, elegant interface
- Automated setup reduces support burden

### ❌ Cons for Inclusion
- Beta software - may be unstable
- High resource requirements (not suitable for all users)
- Requires KVM/virtualization (may not work on all hardware)
- Complex dependencies (Docker, QEMU, libvirt)
- Not suitable for gaming (main Linux gaming use case)
- Potential user confusion (when to use vs. WINE)

### 🎯 Recommendation
**Conditional Inclusion** - Include as optional advanced tool with clear warnings:
- Mark as "Advanced" or "Experimental"
- Require explicit user acknowledgment of beta status
- Provide clear use case guidance (professional apps, not gaming)
- Document resource requirements upfront
- Consider making it opt-in during installation flow

## Testing Checklist

- [ ] Installation on clean Ubuntu 24.04 VM
- [ ] Pre-requisite verification (KVM, Docker)
- [ ] Windows installation through WinBoat interface
- [ ] Application installation and testing
- [ ] Filesystem integration testing
- [ ] USB passthrough testing (if applicable)
- [ ] Resource usage monitoring
- [ ] Performance evaluation (RDP responsiveness)
- [ ] Multi-monitor support testing
- [ ] Clipboard integration testing
- [ ] Audio passthrough testing
- [ ] Network connectivity testing
- [ ] Snapshot/backup functionality
- [ ] Uninstallation testing
- [ ] Documentation accuracy verification

---

**Last Updated**: November 22, 2024  
**Evaluator**: bentobox team  
**Status**: Under evaluation

