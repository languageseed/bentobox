#!/bin/bash
# Bentobox Pre-flight Check System
# Scans system for potential issues before installation
# Checks: apt state, conflicts, already-installed components

# Colors for output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
ERRORS=0
WARNINGS=0
INFO=0

echo "🔍 Bentobox Pre-flight Check"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# =============================================================================
# SYSTEM READINESS CHECKS
# =============================================================================

echo "📋 System Readiness"
echo "─────────────────────────────────────────"

# Check Ubuntu version
UBUNTU_VERSION=$(lsb_release -rs 2>/dev/null || echo "unknown")
if [[ "$UBUNTU_VERSION" =~ ^24\. ]] || [[ "$UBUNTU_VERSION" =~ ^2[5-9]\. ]]; then
    echo -e "  ${GREEN}✓${NC} Ubuntu $UBUNTU_VERSION detected"
else
    echo -e "  ${RED}✗${NC} Ubuntu $UBUNTU_VERSION - Bentobox requires 24.04+"
    ERRORS=$((ERRORS + 1))
fi

# Check if running as root (shouldn't be)
if [ "$EUID" -eq 0 ]; then
    echo -e "  ${YELLOW}⚠${NC} Running as root - bentobox should run as regular user"
    WARNINGS=$((WARNINGS + 1))
else
    echo -e "  ${GREEN}✓${NC} Running as regular user"
fi

# Check sudo access
if sudo -n true 2>/dev/null; then
    echo -e "  ${GREEN}✓${NC} Sudo access available (cached)"
elif sudo -v 2>/dev/null; then
    echo -e "  ${GREEN}✓${NC} Sudo access available"
else
    echo -e "  ${RED}✗${NC} No sudo access - bentobox requires sudo"
    ERRORS=$((ERRORS + 1))
fi

# Check disk space (need at least 15GB)
AVAILABLE_GB=$(df -BG / | awk 'NR==2 {print $4}' | sed 's/G//')
if [ "$AVAILABLE_GB" -ge 30 ]; then
    echo -e "  ${GREEN}✓${NC} Disk space: ${AVAILABLE_GB}GB available (good)"
elif [ "$AVAILABLE_GB" -ge 15 ]; then
    echo -e "  ${YELLOW}⚠${NC} Disk space: ${AVAILABLE_GB}GB available (minimum)"
    WARNINGS=$((WARNINGS + 1))
else
    echo -e "  ${RED}✗${NC} Disk space: ${AVAILABLE_GB}GB available (need 15GB+)"
    ERRORS=$((ERRORS + 1))
fi

# Check memory
TOTAL_RAM_GB=$(free -g | awk '/^Mem:/ {print $2}')
if [ "$TOTAL_RAM_GB" -ge 8 ]; then
    echo -e "  ${GREEN}✓${NC} RAM: ${TOTAL_RAM_GB}GB (good)"
elif [ "$TOTAL_RAM_GB" -ge 4 ]; then
    echo -e "  ${YELLOW}⚠${NC} RAM: ${TOTAL_RAM_GB}GB (minimum, 8GB recommended)"
    WARNINGS=$((WARNINGS + 1))
else
    echo -e "  ${RED}✗${NC} RAM: ${TOTAL_RAM_GB}GB (need 4GB+)"
    ERRORS=$((ERRORS + 1))
fi

# Check internet connectivity
if ping -c 1 -W 2 8.8.8.8 &> /dev/null; then
    echo -e "  ${GREEN}✓${NC} Internet connection active"
else
    echo -e "  ${RED}✗${NC} No internet connection"
    ERRORS=$((ERRORS + 1))
fi

# Check GitHub connectivity
if curl -s --connect-timeout 5 https://github.com > /dev/null 2>&1; then
    echo -e "  ${GREEN}✓${NC} GitHub accessible"
else
    echo -e "  ${YELLOW}⚠${NC} Cannot reach GitHub (may cause issues)"
    WARNINGS=$((WARNINGS + 1))
fi

echo ""

# =============================================================================
# APT SYSTEM CHECKS
# =============================================================================

echo "📦 APT Package System"
echo "─────────────────────────────────────────"

# Check apt lock
if sudo fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1; then
    echo -e "  ${YELLOW}⚠${NC} APT is locked (another process using it)"
    WARNINGS=$((WARNINGS + 1))
else
    echo -e "  ${GREEN}✓${NC} APT is not locked"
fi

# Check apt cache age
if [ -f /var/cache/apt/pkgcache.bin ]; then
    CACHE_AGE=$(( ($(date +%s) - $(stat -c %Y /var/cache/apt/pkgcache.bin)) / 86400 ))
    if [ "$CACHE_AGE" -gt 7 ]; then
        echo -e "  ${YELLOW}⚠${NC} APT cache is ${CACHE_AGE} days old (will run apt update)"
        export BENTOBOX_NEEDS_APT_UPDATE=true
        WARNINGS=$((WARNINGS + 1))
    elif [ "$CACHE_AGE" -gt 0 ]; then
        echo -e "  ${GREEN}✓${NC} APT cache is ${CACHE_AGE} days old (recent)"
    else
        echo -e "  ${GREEN}✓${NC} APT cache is fresh"
    fi
else
    echo -e "  ${YELLOW}⚠${NC} No APT cache found (will run apt update)"
    export BENTOBOX_NEEDS_APT_UPDATE=true
    WARNINGS=$((WARNINGS + 1))
fi

# Check for pending updates
PENDING_UPDATES=$(apt list --upgradable 2>/dev/null | grep -c upgradable || echo "0")
if [ "$PENDING_UPDATES" -gt 50 ]; then
    echo -e "  ${YELLOW}⚠${NC} $PENDING_UPDATES packages have updates available (recommend apt upgrade)"
    export BENTOBOX_NEEDS_APT_UPGRADE=true
    WARNINGS=$((WARNINGS + 1))
elif [ "$PENDING_UPDATES" -gt 0 ]; then
    echo -e "  ${BLUE}ℹ${NC} $PENDING_UPDATES packages have updates available"
    INFO=$((INFO + 1))
else
    echo -e "  ${GREEN}✓${NC} System packages are up to date"
fi

# Check for broken packages
BROKEN=$(dpkg -l | grep "^iU" | wc -l || echo "0")
if [ "$BROKEN" -gt 0 ]; then
    echo -e "  ${RED}✗${NC} $BROKEN broken packages detected"
    echo "     Run: sudo dpkg --configure -a"
    ERRORS=$((ERRORS + 1))
else
    echo -e "  ${GREEN}✓${NC} No broken packages"
fi

echo ""

# =============================================================================
# CONFLICTING PACKAGES CHECK
# =============================================================================

echo "⚠️  Conflicting Packages"
echo "─────────────────────────────────────────"

CONFLICTS_FOUND=0
ALREADY_INSTALLED=0

# Check for conflicting Docker installations
if dpkg -l | grep -q "^ii.*docker.io"; then
    echo -e "  ${YELLOW}⚠${NC} docker.io package installed (bentobox installs docker-ce)"
    echo "     Consider: sudo apt remove docker.io"
    CONFLICTS_FOUND=$((CONFLICTS_FOUND + 1))
    WARNINGS=$((WARNINGS + 1))
fi

if command -v docker &> /dev/null; then
    DOCKER_VERSION=$(docker --version 2>/dev/null || echo "unknown")
    echo -e "  ${BLUE}ℹ${NC} Docker already installed: $DOCKER_VERSION"
    echo -e "  ${GREEN}✓${NC} Auto-skip: Will skip Docker installation"
    export SKIP_DOCKER=true
    ALREADY_INSTALLED=$((ALREADY_INSTALLED + 1))
    
    if [[ "$DOCKER_VERSION" == *"docker.io"* ]]; then
        echo -e "  ${YELLOW}⚠${NC} Docker from Ubuntu repos (bentobox prefers docker-ce)"
    fi
fi

# Check for snap Docker (conflicts with apt Docker)
if snap list 2>/dev/null | grep -q "^docker"; then
    echo -e "  ${YELLOW}⚠${NC} Docker installed via snap (may conflict)"
    echo "     Consider: sudo snap remove docker"
    CONFLICTS_FOUND=$((CONFLICTS_FOUND + 1))
    WARNINGS=$((WARNINGS + 1))
    export SKIP_DOCKER=true
fi

# Check for conflicting Node.js installations
NODE_LOCATIONS=()
command -v node &>/dev/null && NODE_LOCATIONS+=("$(which node)")
[ -f "/usr/bin/node" ] && NODE_LOCATIONS+=("/usr/bin/node")
[ -f "$HOME/.nvm/nvm.sh" ] && NODE_LOCATIONS+=("nvm")

if [ ${#NODE_LOCATIONS[@]} -gt 0 ]; then
    NODE_VERSION=$(node --version 2>/dev/null || echo "unknown")
    echo -e "  ${BLUE}ℹ${NC} Node.js already installed: $NODE_VERSION at ${NODE_LOCATIONS[*]}"
    echo -e "  ${GREEN}✓${NC} Auto-skip: Will skip Node.js installation via mise"
    export SKIP_NODEJS=true
    ALREADY_INSTALLED=$((ALREADY_INSTALLED + 1))
fi

# Check for conflicting Ruby installations
if dpkg -l | grep -q "^ii.*rbenv"; then
    echo -e "  ${YELLOW}⚠${NC} rbenv installed (bentobox uses mise for Ruby)"
    echo -e "  ${GREEN}✓${NC} Auto-skip: Will skip Ruby installation via mise"
    export SKIP_RUBY=true
    CONFLICTS_FOUND=$((CONFLICTS_FOUND + 1))
    WARNINGS=$((WARNINGS + 1))
fi

if [ -d "$HOME/.rvm" ]; then
    echo -e "  ${YELLOW}⚠${NC} RVM installed (bentobox uses mise for Ruby)"
    echo -e "  ${GREEN}✓${NC} Auto-skip: Will skip Ruby installation via mise"
    export SKIP_RUBY=true
    CONFLICTS_FOUND=$((CONFLICTS_FOUND + 1))
    WARNINGS=$((WARNINGS + 1))
fi

if command -v ruby &> /dev/null && [ "$SKIP_RUBY" != "true" ]; then
    RUBY_VERSION=$(ruby --version 2>/dev/null || echo "unknown")
    echo -e "  ${BLUE}ℹ${NC} Ruby already installed: $RUBY_VERSION"
    echo -e "  ${GREEN}✓${NC} Auto-skip: Will skip Ruby installation via mise"
    export SKIP_RUBY=true
    ALREADY_INSTALLED=$((ALREADY_INSTALLED + 1))
fi

# Check for conflicting Python installations
if command -v pyenv &> /dev/null; then
    echo -e "  ${YELLOW}⚠${NC} pyenv installed (bentobox uses mise for Python)"
    echo -e "  ${GREEN}✓${NC} Auto-skip: Will skip Python installation via mise"
    export SKIP_PYTHON=true
    CONFLICTS_FOUND=$((CONFLICTS_FOUND + 1))
    WARNINGS=$((WARNINGS + 1))
fi

if command -v python3 &> /dev/null && [ "$SKIP_PYTHON" != "true" ]; then
    PYTHON_VERSION=$(python3 --version 2>/dev/null || echo "unknown")
    echo -e "  ${BLUE}ℹ${NC} Python already installed: $PYTHON_VERSION"
    echo -e "  ${GREEN}✓${NC} Auto-skip: Will skip Python installation via mise (system Python OK)"
    export SKIP_PYTHON=true
    ALREADY_INSTALLED=$((ALREADY_INSTALLED + 1))
fi

# Check for existing Alacritty
if command -v alacritty &> /dev/null; then
    ALACRITTY_VER=$(alacritty --version 2>/dev/null | head -1 || echo "unknown")
    echo -e "  ${BLUE}ℹ${NC} Alacritty already installed: $ALACRITTY_VER"
    echo -e "  ${GREEN}✓${NC} Auto-skip: Will skip Alacritty installation"
    export SKIP_ALACRITTY=true
    ALREADY_INSTALLED=$((ALREADY_INSTALLED + 1))
fi

# Check for existing VS Code
if command -v code &> /dev/null; then
    VSCODE_VER=$(code --version 2>/dev/null | head -1 || echo "unknown")
    echo -e "  ${BLUE}ℹ${NC} VS Code already installed: $VSCODE_VER"
    echo -e "  ${GREEN}✓${NC} Auto-skip: Will skip VS Code installation"
    export SKIP_VSCODE=true
    ALREADY_INSTALLED=$((ALREADY_INSTALLED + 1))
fi

# Check for existing Cursor
if command -v cursor &> /dev/null; then
    echo -e "  ${BLUE}ℹ${NC} Cursor already installed"
    echo -e "  ${GREEN}✓${NC} Auto-skip: Will skip Cursor installation"
    export SKIP_CURSOR=true
    ALREADY_INSTALLED=$((ALREADY_INSTALLED + 1))
fi

# Check for existing Chrome
if command -v google-chrome &> /dev/null; then
    echo -e "  ${BLUE}ℹ${NC} Chrome already installed"
    echo -e "  ${GREEN}✓${NC} Auto-skip: Will skip Chrome installation"
    export SKIP_CHROME=true
    ALREADY_INSTALLED=$((ALREADY_INSTALLED + 1))
fi

# Check for existing Neovim
if command -v nvim &> /dev/null; then
    NVIM_VER=$(nvim --version 2>/dev/null | head -1 || echo "unknown")
    echo -e "  ${BLUE}ℹ${NC} Neovim already installed: $NVIM_VER"
    echo -e "  ${GREEN}✓${NC} Auto-skip: Will skip Neovim installation"
    export SKIP_NEOVIM=true
    ALREADY_INSTALLED=$((ALREADY_INSTALLED + 1))
fi

# Check for existing WinBoat (virt-manager/libvirt)
if command -v virt-manager &> /dev/null; then
    VIRT_VER=$(virt-manager --version 2>&1 | head -1 || echo "unknown")
    echo -e "  ${BLUE}ℹ${NC} WinBoat (virt-manager) already installed: $VIRT_VER"
    echo -e "  ${GREEN}✓${NC} Auto-skip: Will skip WinBoat installation"
    export SKIP_WINBOAT=true
    ALREADY_INSTALLED=$((ALREADY_INSTALLED + 1))
fi

if [ $CONFLICTS_FOUND -eq 0 ]; then
    echo -e "  ${GREEN}✓${NC} No conflicting packages detected"
fi

echo ""

# =============================================================================
# ALREADY INSTALLED COMPONENTS
# =============================================================================

echo "📦 Already Installed Components"
echo "─────────────────────────────────────────"

# Check for previous bentobox installation
if [ -d "$HOME/.local/share/omakub" ]; then
    echo -e "  ${BLUE}ℹ${NC} Previous bentobox installation found"
    echo "     Location: $HOME/.local/share/omakub"
    ALREADY_INSTALLED=$((ALREADY_INSTALLED + 1))
fi

# Check Docker
if command -v docker &> /dev/null; then
    DOCKER_VER=$(docker --version 2>/dev/null | cut -d' ' -f3 | tr -d ',')
    echo -e "  ${BLUE}ℹ${NC} Docker $DOCKER_VER installed"
    ALREADY_INSTALLED=$((ALREADY_INSTALLED + 1))
fi

# Check containers
if command -v docker &> /dev/null && docker ps &> /dev/null; then
    RUNNING=$(docker ps --format '{{.Names}}' 2>/dev/null)
    if echo "$RUNNING" | grep -q "portainer"; then
        echo -e "  ${BLUE}ℹ${NC} Portainer container already running"
        echo -e "  ${GREEN}✓${NC} Auto-skip: Will skip Portainer installation"
        export SKIP_PORTAINER=true
        ALREADY_INSTALLED=$((ALREADY_INSTALLED + 1))
    fi
    if echo "$RUNNING" | grep -q "open-webui"; then
        echo -e "  ${BLUE}ℹ${NC} OpenWebUI container already running"
        echo -e "  ${GREEN}✓${NC} Auto-skip: Will skip OpenWebUI installation"
        export SKIP_OPENWEBUI=true
        ALREADY_INSTALLED=$((ALREADY_INSTALLED + 1))
    fi
    if echo "$RUNNING" | grep -q "ollama"; then
        echo -e "  ${BLUE}ℹ${NC} Ollama container already running"
        echo -e "  ${GREEN}✓${NC} Auto-skip: Will skip Ollama installation"
        export SKIP_OLLAMA=true
        ALREADY_INSTALLED=$((ALREADY_INSTALLED + 1))
    fi
fi

# Check for development tools
if command -v mise &> /dev/null; then
    echo -e "  ${BLUE}ℹ${NC} mise (language version manager) installed"
    ALREADY_INSTALLED=$((ALREADY_INSTALLED + 1))
fi

if command -v gh &> /dev/null; then
    echo -e "  ${BLUE}ℹ${NC} GitHub CLI installed"
    ALREADY_INSTALLED=$((ALREADY_INSTALLED + 1))
fi

if command -v lazygit &> /dev/null; then
    echo -e "  ${BLUE}ℹ${NC} lazygit installed"
    ALREADY_INSTALLED=$((ALREADY_INSTALLED + 1))
fi

if [ $ALREADY_INSTALLED -eq 0 ]; then
    echo -e "  ${GREEN}✓${NC} No previous installation detected (clean system)"
fi

echo ""

# =============================================================================
# DESKTOP ENVIRONMENT CHECK
# =============================================================================

echo "🖥️  Desktop Environment"
echo "─────────────────────────────────────────"

if [[ "$XDG_CURRENT_DESKTOP" == *"GNOME"* ]]; then
    GNOME_VER=$(gnome-shell --version 2>/dev/null | cut -d' ' -f3 || echo "unknown")
    echo -e "  ${GREEN}✓${NC} GNOME $GNOME_VER detected"
    echo -e "  ${GREEN}✓${NC} Desktop applications will be installed"
elif [ -n "$XDG_CURRENT_DESKTOP" ]; then
    echo -e "  ${YELLOW}⚠${NC} Desktop: $XDG_CURRENT_DESKTOP (not GNOME)"
    echo "     Desktop applications will be skipped"
    WARNINGS=$((WARNINGS + 1))
else
    echo -e "  ${BLUE}ℹ${NC} No desktop environment detected"
    echo "     Only terminal tools will be installed"
    INFO=$((INFO + 1))
fi

echo ""

# =============================================================================
# VIRTUALIZATION CHECK (for WinBoat)
# =============================================================================

echo "🖥️  Virtualization Support"
echo "─────────────────────────────────────────"

if egrep -q '(vmx|svm)' /proc/cpuinfo 2>/dev/null; then
    VT_TYPE=$(egrep -o '(vmx|svm)' /proc/cpuinfo | head -1)
    echo -e "  ${GREEN}✓${NC} Hardware virtualization supported ($VT_TYPE)"
    echo "     WinBoat can be installed"
else
    echo -e "  ${YELLOW}⚠${NC} No hardware virtualization support"
    echo "     WinBoat will not work"
    WARNINGS=$((WARNINGS + 1))
fi

if [ -e /dev/kvm ]; then
    echo -e "  ${GREEN}✓${NC} /dev/kvm exists (KVM ready)"
else
    echo -e "  ${BLUE}ℹ${NC} /dev/kvm not found (will be created if needed)"
fi

echo ""

# =============================================================================
# AUTO-ADJUSTMENT SUMMARY
# =============================================================================

SKIP_COUNT=0
[ "$SKIP_DOCKER" = "true" ] && SKIP_COUNT=$((SKIP_COUNT + 1))
[ "$SKIP_NODEJS" = "true" ] && SKIP_COUNT=$((SKIP_COUNT + 1))
[ "$SKIP_RUBY" = "true" ] && SKIP_COUNT=$((SKIP_COUNT + 1))
[ "$SKIP_PYTHON" = "true" ] && SKIP_COUNT=$((SKIP_COUNT + 1))
[ "$SKIP_ALACRITTY" = "true" ] && SKIP_COUNT=$((SKIP_COUNT + 1))
[ "$SKIP_VSCODE" = "true" ] && SKIP_COUNT=$((SKIP_COUNT + 1))
[ "$SKIP_CURSOR" = "true" ] && SKIP_COUNT=$((SKIP_COUNT + 1))
[ "$SKIP_CHROME" = "true" ] && SKIP_COUNT=$((SKIP_COUNT + 1))
[ "$SKIP_NEOVIM" = "true" ] && SKIP_COUNT=$((SKIP_COUNT + 1))
[ "$SKIP_WINBOAT" = "true" ] && SKIP_COUNT=$((SKIP_COUNT + 1))
[ "$SKIP_PORTAINER" = "true" ] && SKIP_COUNT=$((SKIP_COUNT + 1))
[ "$SKIP_OPENWEBUI" = "true" ] && SKIP_COUNT=$((SKIP_COUNT + 1))
[ "$SKIP_OLLAMA" = "true" ] && SKIP_COUNT=$((SKIP_COUNT + 1))

if [ $SKIP_COUNT -gt 0 ]; then
    echo "🔧 Auto-Adjustment Summary"
    echo "─────────────────────────────────────────"
    echo -e "${GREEN}✓ Installation plan automatically adjusted${NC}"
    echo -e "  Skipping $SKIP_COUNT already-installed component(s):"
    echo ""
    [ "$SKIP_DOCKER" = "true" ] && echo "  • Docker (already installed)"
    [ "$SKIP_NODEJS" = "true" ] && echo "  • Node.js (already installed)"
    [ "$SKIP_RUBY" = "true" ] && echo "  • Ruby (already installed)"
    [ "$SKIP_PYTHON" = "true" ] && echo "  • Python (already installed)"
    [ "$SKIP_ALACRITTY" = "true" ] && echo "  • Alacritty (already installed)"
    [ "$SKIP_VSCODE" = "true" ] && echo "  • VS Code (already installed)"
    [ "$SKIP_CURSOR" = "true" ] && echo "  • Cursor (already installed)"
    [ "$SKIP_CHROME" = "true" ] && echo "  • Chrome (already installed)"
    [ "$SKIP_NEOVIM" = "true" ] && echo "  • Neovim (already installed)"
    [ "$SKIP_WINBOAT" = "true" ] && echo "  • WinBoat (already installed)"
    [ "$SKIP_PORTAINER" = "true" ] && echo "  • Portainer container (already running)"
    [ "$SKIP_OPENWEBUI" = "true" ] && echo "  • OpenWebUI container (already running)"
    [ "$SKIP_OLLAMA" = "true" ] && echo "  • Ollama container (already running)"
    echo ""
fi

# =============================================================================
# SUMMARY
# =============================================================================

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 Pre-flight Summary"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ $ERRORS -gt 0 ]; then
    echo -e "${RED}✗ $ERRORS critical issue(s) found${NC}"
fi

if [ $WARNINGS -gt 0 ]; then
    echo -e "${YELLOW}⚠ $WARNINGS warning(s) found${NC}"
fi

if [ $INFO -gt 0 ]; then
    echo -e "${BLUE}ℹ $INFO info message(s)${NC}"
fi

if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}✓ System ready for bentobox installation!${NC}"
fi

echo ""

# =============================================================================
# RECOMMENDATIONS
# =============================================================================

if [ $ERRORS -gt 0 ] || [ $WARNINGS -gt 0 ]; then
    echo "💡 Recommendations"
    echo "─────────────────────────────────────────"
    
    if [ "$BENTOBOX_NEEDS_APT_UPDATE" = "true" ]; then
        echo "  • Run: sudo apt update"
    fi
    
    if [ "$BENTOBOX_NEEDS_APT_UPGRADE" = "true" ]; then
        echo "  • Run: sudo apt upgrade -y"
    fi
    
    if [ $CONFLICTS_FOUND -gt 0 ]; then
        echo "  • Review conflicting packages above"
        echo "  • Consider removing conflicts before installation"
    fi
    
    if [ $ALREADY_INSTALLED -gt 0 ]; then
        echo "  • Some components already installed"
        echo "  • Installation will skip or update them"
    fi
    
    echo ""
fi

# =============================================================================
# EXPORT RESULTS
# =============================================================================

export BENTOBOX_PREFLIGHT_ERRORS=$ERRORS
export BENTOBOX_PREFLIGHT_WARNINGS=$WARNINGS
export BENTOBOX_PREFLIGHT_INFO=$INFO

# Exit with error if critical issues found
if [ $ERRORS -gt 0 ]; then
    echo -e "${RED}❌ Cannot proceed with installation due to critical issues${NC}"
    echo ""
    exit 1
fi

# Return success
echo -e "${GREEN}✅ Pre-flight check complete${NC}"
echo ""

# Return 0 if no errors, 2 if warnings (use return since this is sourced)
[ $WARNINGS -gt 0 ] && exit 2 || exit 0

