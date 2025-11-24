#!/bin/bash
# Bentobox TUI Helpers
# Wrapper functions for gum with fallbacks for terminals that don't support it

# Function: bentobox_choose
# Multi-select menu with fallback
bentobox_choose() {
    local items=("$@")
    local header=""
    local selected=""
    local height=10
    local no_limit=false
    
    # Parse flags
    while [[ $# -gt 0 ]]; do
        case $1 in
            --header)
                header="$2"
                shift 2
                ;;
            --selected)
                selected="$2"
                shift 2
                ;;
            --height)
                height="$2"
                shift 2
                ;;
            --no-limit)
                no_limit=true
                shift
                ;;
            *)
                break
                ;;
        esac
    done
    
    items=("$@")
    
    # Use gum if available and working
    if [ "$BENTOBOX_SIMPLE_PROMPTS" != "true" ] && command -v gum &> /dev/null; then
        if [ "$no_limit" = true ]; then
            gum choose "${items[@]}" --no-limit --selected "$selected" --height "$height" --header "$header"
        else
            gum choose "${items[@]}" --selected "$selected" --height "$height" --header "$header"
        fi
    else
        # Fallback to simple prompt
        echo "$header"
        echo "────────────────────────────────────────"
        
        local i=1
        for item in "${items[@]}"; do
            # Check if item should be pre-selected
            if echo "$selected" | grep -q "$item"; then
                echo "  [$i] $item (default)"
            else
                echo "  [$i] $item"
            fi
            ((i++))
        done
        
        echo ""
        if [ "$no_limit" = true ]; then
            read -p "Enter numbers (space-separated, or press Enter for defaults): " choices
            
            if [ -z "$choices" ]; then
                # Use defaults
                echo "$selected" | tr ',' '\n'
            else
                # Convert numbers to selections
                for num in $choices; do
                    if [ "$num" -ge 1 ] && [ "$num" -le "${#items[@]}" ]; then
                        echo "${items[$((num-1))]}"
                    fi
                done
            fi
        else
            read -p "Enter number (or press Enter for default): " choice
            
            if [ -z "$choice" ]; then
                echo "$selected"
            elif [ "$choice" -ge 1 ] && [ "$choice" -le "${#items[@]}" ]; then
                echo "${items[$((choice-1))]}"
            else
                echo "$selected"
            fi
        fi
    fi
}

# Function: bentobox_input
# Text input with fallback
bentobox_input() {
    local prompt="Input> "
    local placeholder=""
    local value=""
    
    # Parse flags
    while [[ $# -gt 0 ]]; do
        case $1 in
            --prompt)
                prompt="$2"
                shift 2
                ;;
            --placeholder)
                placeholder="$2"
                shift 2
                ;;
            --value)
                value="$2"
                shift 2
                ;;
            *)
                shift
                ;;
        esac
    done
    
    # Use gum if available and working
    if [ "$BENTOBOX_SIMPLE_PROMPTS" != "true" ] && command -v gum &> /dev/null; then
        gum input --prompt "$prompt" --placeholder "$placeholder" --value "$value"
    else
        # Fallback to read
        if [ -n "$placeholder" ]; then
            echo "$placeholder"
        fi
        if [ -n "$value" ]; then
            read -p "$prompt" -i "$value" -e user_input
        else
            read -p "$prompt" user_input
        fi
        echo "$user_input"
    fi
}

# Function: bentobox_confirm
# Yes/No confirmation with fallback
bentobox_confirm() {
    local prompt="${1:-Continue?}"
    
    # Use gum if available and working
    if [ "$BENTOBOX_SIMPLE_PROMPTS" != "true" ] && command -v gum &> /dev/null; then
        gum confirm "$prompt"
        return $?
    else
        # Fallback to read
        read -p "$prompt (y/N) " -n 1 -r
        echo
        [[ $REPLY =~ ^[Yy]$ ]]
        return $?
    fi
}

# Function: bentobox_spin
# Spinner for long operations with fallback
bentobox_spin() {
    local title="$1"
    shift
    local command="$@"
    
    # Use gum if available and working
    if [ "$BENTOBOX_SIMPLE_PROMPTS" != "true" ] && command -v gum &> /dev/null; then
        gum spin --spinner dot --title "$title" -- bash -c "$command"
    else
        # Fallback to simple echo
        echo "$title..."
        bash -c "$command"
    fi
}

# Function: bentobox_style
# Styled text output with fallback
bentobox_style() {
    local text=""
    local foreground=""
    local bold=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --foreground)
                foreground="$2"
                shift 2
                ;;
            --bold)
                bold=true
                shift
                ;;
            *)
                text="$1"
                shift
                ;;
        esac
    done
    
    # Use gum if available and not forced to simple
    if [ "$BENTOBOX_SIMPLE_PROMPTS" != "true" ] && [ "$BENTOBOX_NO_COLOR" != "true" ] && command -v gum &> /dev/null; then
        if [ "$bold" = true ] && [ -n "$foreground" ]; then
            gum style --foreground "$foreground" --bold "$text"
        elif [ "$bold" = true ]; then
            gum style --bold "$text"
        elif [ -n "$foreground" ]; then
            gum style --foreground "$foreground" "$text"
        else
            echo "$text"
        fi
    else
        # Fallback to plain text
        echo "$text"
    fi
}

# Export functions for use in subscripts
export -f bentobox_choose
export -f bentobox_input
export -f bentobox_confirm
export -f bentobox_spin
export -f bentobox_style

