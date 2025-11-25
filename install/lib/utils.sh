#!/bin/bash
# Utility functions for Bentobox distribution abstraction

# ============================================================================
# LOGGING UTILITIES
# ============================================================================

# Color codes
BENTOBOX_COLOR_RED='\033[0;31m'
BENTOBOX_COLOR_GREEN='\033[0;32m'
BENTOBOX_COLOR_YELLOW='\033[1;33m'
BENTOBOX_COLOR_BLUE='\033[0;34m'
BENTOBOX_COLOR_NC='\033[0m' # No Color

# Log an error message
log_error() {
    echo -e "${BENTOBOX_COLOR_RED}❌ $*${BENTOBOX_COLOR_NC}" >&2
}

# Log a warning message
log_warn() {
    echo -e "${BENTOBOX_COLOR_YELLOW}⚠️  $*${BENTOBOX_COLOR_NC}" >&2
}

# Log an info message
log_info() {
    echo -e "${BENTOBOX_COLOR_BLUE}ℹ️  $*${BENTOBOX_COLOR_NC}"
}

# Log a success message
log_success() {
    echo -e "${BENTOBOX_COLOR_GREEN}✓ $*${BENTOBOX_COLOR_NC}"
}

# ============================================================================
# COMMAND UTILITIES
# ============================================================================

# Check if a command exists
command_exists() {
    command -v "$1" &>/dev/null
}

# Check if running as root
is_root() {
    [ "$EUID" -eq 0 ]
}

# Check if running with sudo access
has_sudo() {
    sudo -n true 2>/dev/null
}

# ============================================================================
# FILE UTILITIES
# ============================================================================

# Create a backup of a file
backup_file() {
    local file="$1"
    if [ -f "$file" ]; then
        local backup="${file}.bak.$(date +%Y%m%d%H%M%S)"
        cp "$file" "$backup"
        log_info "Backed up $file to $backup"
    fi
}

# Check if a file exists and is not empty
file_not_empty() {
    [ -f "$1" ] && [ -s "$1" ]
}

# ============================================================================
# STRING UTILITIES
# ============================================================================

# Trim whitespace from string
trim() {
    local var="$*"
    # Remove leading whitespace
    var="${var#"${var%%[![:space:]]*}"}"
    # Remove trailing whitespace
    var="${var%"${var##*[![:space:]]}"}"
    echo "$var"
}

# Convert string to lowercase
to_lower() {
    echo "$*" | tr '[:upper:]' '[:lower:]'
}

# Convert string to uppercase
to_upper() {
    echo "$*" | tr '[:lower:]' '[:upper:]'
}

# ============================================================================
# VERSION COMPARISON
# ============================================================================

# Compare two version strings
# Returns: 0 if equal, 1 if version1 > version2, 2 if version1 < version2
version_compare() {
    local version1="$1"
    local version2="$2"
    
    if [ "$version1" = "$version2" ]; then
        return 0
    fi
    
    local IFS=.
    local i ver1=($version1) ver2=($version2)
    
    # Fill empty positions with zeros
    for ((i=${#ver1[@]}; i<${#ver2[@]}; i++)); do
        ver1[i]=0
    done
    
    for ((i=0; i<${#ver1[@]}; i++)); do
        if [ -z "${ver2[i]}" ]; then
            ver2[i]=0
        fi
        if ((10#${ver1[i]} > 10#${ver2[i]})); then
            return 1
        fi
        if ((10#${ver1[i]} < 10#${ver2[i]})); then
            return 2
        fi
    done
    
    return 0
}

# Check if version1 >= version2
version_gte() {
    version_compare "$1" "$2"
    local result=$?
    [ $result -eq 0 ] || [ $result -eq 1 ]
}

# Check if version1 > version2
version_gt() {
    version_compare "$1" "$2"
    [ $? -eq 1 ]
}

# Check if version1 <= version2
version_lte() {
    version_compare "$1" "$2"
    local result=$?
    [ $result -eq 0 ] || [ $result -eq 2 ]
}

# Check if version1 < version2
version_lt() {
    version_compare "$1" "$2"
    [ $? -eq 2 ]
}

# ============================================================================
# CONFIRMATION UTILITIES
# ============================================================================

# Ask for user confirmation
# Returns: 0 if yes, 1 if no
confirm() {
    local prompt="$1"
    local default="${2:-n}"
    
    if [ "$default" = "y" ] || [ "$default" = "Y" ]; then
        prompt="$prompt [Y/n] "
    else
        prompt="$prompt [y/N] "
    fi
    
    read -p "$prompt" -n 1 -r
    echo
    
    if [ "$default" = "y" ] || [ "$default" = "Y" ]; then
        [[ ! $REPLY =~ ^[Nn]$ ]]
    else
        [[ $REPLY =~ ^[Yy]$ ]]
    fi
}

# ============================================================================
# PROGRESS UTILITIES
# ============================================================================

# Show a spinner for a background process
spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\\'
    
    while kill -0 $pid 2>/dev/null; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

# ============================================================================
# NETWORK UTILITIES
# ============================================================================

# Check if internet connection is available
has_internet() {
    ping -c 1 -W 2 8.8.8.8 &>/dev/null
}

# Check if a URL is reachable
url_exists() {
    local url="$1"
    if command_exists curl; then
        curl -s --head "$url" | head -n 1 | grep "HTTP/[12].[01] [23].." &>/dev/null
    elif command_exists wget; then
        wget --spider -q "$url"
    else
        log_error "Neither curl nor wget available"
        return 1
    fi
}

# ============================================================================
# ARCHITECTURE DETECTION
# ============================================================================

# Get system architecture
get_arch() {
    uname -m
}

# Check if running on x86_64
is_x86_64() {
    [ "$(get_arch)" = "x86_64" ]
}

# Check if running on ARM
is_arm() {
    local arch=$(get_arch)
    [[ "$arch" =~ ^arm ]] || [[ "$arch" =~ ^aarch64 ]]
}

# ============================================================================
# CLEANUP UTILITIES
# ============================================================================

# Set up cleanup trap
setup_cleanup() {
    trap cleanup EXIT INT TERM
}

# Default cleanup function (can be overridden)
cleanup() {
    log_info "Cleaning up..."
    # Override this function in your script if needed
}

