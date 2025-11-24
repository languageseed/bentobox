#!/bin/bash
# Terminal Compatibility Check & Setup
# Ensures TUI (gum) works properly in terminal, SSH, and various environments

echo "🖥️  Terminal Compatibility Check"
echo ""

# Check terminal type
if [ -z "$TERM" ]; then
    echo "⚠️  Warning: TERM environment variable not set"
    export TERM=xterm-256color
    echo "   Set TERM=xterm-256color as fallback"
elif [ "$TERM" = "dumb" ]; then
    echo "⚠️  Warning: TERM=dumb detected (limited terminal)"
    echo "   TUI features may not work properly"
    export BENTOBOX_SIMPLE_PROMPTS=true
fi

# Check if running over SSH
if [ -n "$SSH_CONNECTION" ] || [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
    echo "🌐 SSH session detected"
    export BENTOBOX_SSH_SESSION=true
    
    # Check if terminal supports colors
    if tput colors &>/dev/null && [ "$(tput colors)" -ge 256 ]; then
        echo "   ✓ 256-color support available"
    elif tput colors &>/dev/null && [ "$(tput colors)" -ge 8 ]; then
        echo "   ⚠ Basic color support (8 colors)"
    else
        echo "   ⚠ No color support detected"
        export BENTOBOX_NO_COLOR=true
    fi
else
    echo "💻 Local terminal session"
    export BENTOBOX_SSH_SESSION=false
fi

# Check terminal size
if command -v tput &> /dev/null; then
    COLS=$(tput cols 2>/dev/null || echo "80")
    LINES=$(tput lines 2>/dev/null || echo "24")
    
    if [ "$COLS" -lt 80 ]; then
        echo "⚠️  Warning: Terminal width is ${COLS} columns (recommend 80+)"
        echo "   Some TUI elements may not display correctly"
    fi
    
    if [ "$LINES" -lt 24 ]; then
        echo "⚠️  Warning: Terminal height is ${LINES} lines (recommend 24+)"
        echo "   Some menus may be truncated"
    fi
    
    if [ "$COLS" -ge 80 ] && [ "$LINES" -ge 24 ]; then
        echo "   ✓ Terminal size: ${COLS}x${LINES} (good)"
    fi
else
    echo "⚠️  Cannot detect terminal size (tput not available)"
fi

# Check if stdin is a terminal (important for gum)
if [ -t 0 ]; then
    echo "   ✓ Interactive terminal (stdin is a TTY)"
else
    echo "   ⚠ Non-interactive stdin detected"
    echo "   TUI prompts may not work (consider using config file)"
    export BENTOBOX_SIMPLE_PROMPTS=true
fi

# Check if gum will work
if command -v gum &> /dev/null; then
    # Test gum in current terminal (with timeout to avoid hanging)
    if timeout 2 bash -c 'echo "test" | gum choose "test" --limit 1' &>/dev/null; then
        echo "   ✓ gum TUI works in this terminal"
        export BENTOBOX_GUM_WORKS=true
    else
        echo "   ⚠ gum may not work properly in this terminal"
        echo "   Will use simple text prompts as fallback"
        export BENTOBOX_GUM_WORKS=false
        export BENTOBOX_SIMPLE_PROMPTS=true
    fi
fi

# Set terminal title if supported
if [ -n "$TERM" ] && [ "$TERM" != "dumb" ]; then
    echo -ne "\033]0;Bentobox Installation\007" 2>/dev/null || true
fi

echo ""

# Export terminal info for scripts
export BENTOBOX_TERM_COLS="${COLS:-80}"
export BENTOBOX_TERM_LINES="${LINES:-24}"

# Summary
if [ "$BENTOBOX_SIMPLE_PROMPTS" = "true" ]; then
    echo "📋 Using simple text prompts (TUI not available)"
elif [ "$BENTOBOX_SSH_SESSION" = "true" ]; then
    echo "✅ Terminal ready (SSH with TUI support)"
else
    echo "✅ Terminal ready (local with TUI support)"
fi

echo ""

