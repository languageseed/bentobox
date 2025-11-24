#!/bin/bash
# Pre-Installation Component Selection Menu
# Runs BEFORE pre-flight to let users choose what to install

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo ""
echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   Bentobox Installation Setup         ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""
echo "Choose components to install on this system."
echo "Pre-flight check will run next to detect conflicts."
echo ""

# =============================================================================
# DESKTOP APPLICATIONS (only if GNOME detected)
# =============================================================================

if command -v gnome-shell &> /dev/null || [[ "$XDG_CURRENT_DESKTOP" == *"GNOME"* ]]; then
  echo -e "${GREEN}━━━ Desktop Applications ━━━${NC}"
  echo ""
  
  AVAILABLE_OPTIONAL_APPS=(
    "1password"
    "ASDControl" 
    "Brave"
    "Cursor"
    "GIMP"
    "Mainline-Kernels"
    "OBS-Studio"
    "RubyMine"
    "Sublime-Text"
    "Tailscale"
    "WinBoat"
    "Windows-10-ISO"
  )
  
  DEFAULT_OPTIONAL_APPS="1password,Tailscale"
  
  if command -v gum &> /dev/null && [ "$BENTOBOX_SIMPLE_PROMPTS" != "true" ]; then
    export OMAKUB_FIRST_RUN_OPTIONAL_APPS=$(gum choose "${AVAILABLE_OPTIONAL_APPS[@]}" \
      --no-limit \
      --selected "$DEFAULT_OPTIONAL_APPS" \
      --height 13 \
      --header "Select optional desktop applications (Space=select, Enter=confirm)")
  else
    # Fallback for terminals without gum support
    echo "Available optional applications:"
    echo "────────────────────────────────────────"
    for i in "${!AVAILABLE_OPTIONAL_APPS[@]}"; do
      num=$((i + 1))
      app="${AVAILABLE_OPTIONAL_APPS[$i]}"
      if [[ "$DEFAULT_OPTIONAL_APPS" == *"$app"* ]]; then
        echo "  [$num] $app (default)"
      else
        echo "  [$num] $app"
      fi
    done
    echo ""
    read -p "Enter numbers (space-separated, or Enter for defaults): " choices
    
    if [ -z "$choices" ]; then
      export OMAKUB_FIRST_RUN_OPTIONAL_APPS=$(echo "$DEFAULT_OPTIONAL_APPS" | tr ',' '\n')
    else
      selected=""
      for num in $choices; do
        idx=$((num - 1))
        if [ $idx -ge 0 ] && [ $idx -lt ${#AVAILABLE_OPTIONAL_APPS[@]} ]; then
          app="${AVAILABLE_OPTIONAL_APPS[$idx]}"
          [ -n "$selected" ] && selected="$selected
"
          selected="$selected$app"
        fi
      done
      export OMAKUB_FIRST_RUN_OPTIONAL_APPS="$selected"
    fi
  fi
  
  echo ""
fi

# =============================================================================
# PROGRAMMING LANGUAGES
# =============================================================================

echo -e "${GREEN}━━━ Programming Languages ━━━${NC}"
echo ""

AVAILABLE_LANGUAGES=("Ruby on Rails" "Node.js" "Go" "PHP" "Python" "Elixir" "Rust" "Java")
SELECTED_LANGUAGES="Node.js,Python"

if command -v gum &> /dev/null && [ "$BENTOBOX_SIMPLE_PROMPTS" != "true" ]; then
  export OMAKUB_FIRST_RUN_LANGUAGES=$(gum choose "${AVAILABLE_LANGUAGES[@]}" \
    --no-limit \
    --selected "$SELECTED_LANGUAGES" \
    --height 10 \
    --header "Select programming languages (Space=select, Enter=confirm)")
else
  # Fallback
  echo "Available programming languages:"
  echo "────────────────────────────────────────"
  for i in "${!AVAILABLE_LANGUAGES[@]}"; do
    num=$((i + 1))
    lang="${AVAILABLE_LANGUAGES[$i]}"
    if [[ "$SELECTED_LANGUAGES" == *"$lang"* ]]; then
      echo "  [$num] $lang (default)"
    else
      echo "  [$num] $lang"
    fi
  done
  echo ""
  read -p "Enter numbers (space-separated, or Enter for defaults): " choices
  
  if [ -z "$choices" ]; then
    export OMAKUB_FIRST_RUN_LANGUAGES=$(echo "$SELECTED_LANGUAGES" | tr ',' '\n')
  else
    selected=""
    for num in $choices; do
      idx=$((num - 1))
      if [ $idx -ge 0 ] && [ $idx -lt ${#AVAILABLE_LANGUAGES[@]} ]; then
        lang="${AVAILABLE_LANGUAGES[$idx]}"
        [ -n "$selected" ] && selected="$selected
"
        selected="$selected$lang"
      fi
    done
    export OMAKUB_FIRST_RUN_LANGUAGES="$selected"
  fi
fi

echo ""

# =============================================================================
# DOCKER CONTAINERS
# =============================================================================

echo -e "${GREEN}━━━ Docker Containers ━━━${NC}"
echo ""

AVAILABLE_CONTAINERS=("Portainer" "OpenWebUI" "Ollama")
SELECTED_CONTAINERS="Portainer,OpenWebUI"

if command -v gum &> /dev/null && [ "$BENTOBOX_SIMPLE_PROMPTS" != "true" ]; then
  export OMAKUB_FIRST_RUN_CONTAINERS=$(gum choose "${AVAILABLE_CONTAINERS[@]}" \
    --no-limit \
    --selected "$SELECTED_CONTAINERS" \
    --height 5 \
    --header "Select Docker containers to deploy (Space=select, Enter=confirm)")
else
  # Fallback
  echo "Available Docker containers:"
  echo "────────────────────────────────────────"
  for i in "${!AVAILABLE_CONTAINERS[@]}"; do
    num=$((i + 1))
    container="${AVAILABLE_CONTAINERS[$i]}"
    if [[ "$SELECTED_CONTAINERS" == *"$container"* ]]; then
      echo "  [$num] $container (default)"
    else
      echo "  [$num] $container"
    fi
  done
  echo ""
  read -p "Enter numbers (space-separated, or Enter for defaults): " choices
  
  if [ -z "$choices" ]; then
    export OMAKUB_FIRST_RUN_CONTAINERS=$(echo "$SELECTED_CONTAINERS" | tr ',' '\n')
  else
    selected=""
    for num in $choices; do
      idx=$((num - 1))
      if [ $idx -ge 0 ] && [ $idx -lt ${#AVAILABLE_CONTAINERS[@]} ]; then
        container="${AVAILABLE_CONTAINERS[$idx]}"
        [ -n "$selected" ] && selected="$selected
"
        selected="$selected$container"
      fi
    done
    export OMAKUB_FIRST_RUN_CONTAINERS="$selected"
  fi
fi

echo ""

# =============================================================================
# SUMMARY
# =============================================================================

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✓ Component selection complete${NC}"
echo ""
echo "Selected components:"

if [ -n "$OMAKUB_FIRST_RUN_OPTIONAL_APPS" ]; then
  echo "  Desktop Apps: $(echo "$OMAKUB_FIRST_RUN_OPTIONAL_APPS" | tr '\n' ', ' | sed 's/,$//')"
fi

if [ -n "$OMAKUB_FIRST_RUN_LANGUAGES" ]; then
  echo "  Languages: $(echo "$OMAKUB_FIRST_RUN_LANGUAGES" | tr '\n' ', ' | sed 's/,$//')"
fi

if [ -n "$OMAKUB_FIRST_RUN_CONTAINERS" ]; then
  echo "  Containers: $(echo "$OMAKUB_FIRST_RUN_CONTAINERS" | tr '\n' ', ' | sed 's/,$//')"
fi

echo ""
echo "Next: Pre-flight check will scan for existing installations..."
echo ""

