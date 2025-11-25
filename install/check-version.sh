#!/bin/bash
# Bentobox Version Check
# Verifies system requirements before installation

if [ ! -f /etc/os-release ]; then
  echo "$(tput setaf 1)Error: Unable to determine OS. /etc/os-release file not found."
  echo "Installation stopped."
  exit 1
fi

. /etc/os-release

# Check if running on supported distribution
case "$ID" in
  ubuntu|pop|elementary|mint|neon)
    # Ubuntu 24.04 or higher required
    MAJOR_VERSION="${VERSION_ID%%.*}"
    if [ $(echo "$VERSION_ID >= 24.04" | bc) != 1 ]; then
      echo "$(tput setaf 1)Error: OS requirement not met"
      echo "You are currently running: $PRETTY_NAME"
      echo "OS required: Ubuntu 24.04 or higher"
      echo "Installation stopped."
      exit 1
    fi
    echo "✓ Detected: $PRETTY_NAME (Ubuntu-based)"
    ;;
  
  debian|raspbian)
    # Debian 13 (Trixie) or higher required
    MAJOR_VERSION="${VERSION_ID%%.*}"
    if [ "$MAJOR_VERSION" -lt 13 ]; then
      echo "$(tput setaf 1)Error: OS requirement not met"
      echo "You are currently running: $PRETTY_NAME"
      echo "OS required: Debian 13 (Trixie) or higher"
      echo "Note: Debian 12 (Bookworm) may work but is not officially supported"
      echo "Installation stopped."
      exit 1
    fi
    echo "✓ Detected: $PRETTY_NAME (Debian-based)"
    ;;
  
  *)
    echo "$(tput setaf 1)Error: Unsupported distribution"
    echo "You are currently running: $PRETTY_NAME"
    echo ""
    echo "Bentobox supports:"
    echo "  • Ubuntu 24.04+ (and derivatives: Pop!_OS, Elementary, Mint, KDE Neon)"
    echo "  • Debian 13+ (Trixie)"
    echo ""
    echo "Installation stopped."
    exit 1
    ;;
esac

# Check if running on x86_64 or ARM
ARCH=$(uname -m)
case "$ARCH" in
  x86_64|i686)
    echo "✓ Architecture: $ARCH (supported)"
    ;;
  aarch64|armv7l)
    echo "⚠️  Architecture: $ARCH (ARM - limited support)"
    echo "   Some packages may not be available"
    ;;
  *)
    echo "$(tput setaf 1)Error: Unsupported architecture detected"
    echo "Current architecture: $ARCH"
    echo "Supported architectures: x86_64, i686, aarch64 (ARM64)"
    echo "Installation stopped."
    exit 1
    ;;
esac
