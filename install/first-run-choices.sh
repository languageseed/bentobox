#!/bin/bash

# Load TUI helpers (with fallbacks)
source "$OMAKUB_PATH/install/tui-helpers.sh" 2>/dev/null || true

# Only ask for default desktop app choices when running Gnome
if [[ "$XDG_CURRENT_DESKTOP" == *"GNOME"* ]]; then
  OPTIONAL_APPS=("1password" "Barrier" "Tailscale" "WinBoat" "Sublime-Text")
  DEFAULT_OPTIONAL_APPS='1password'
  
  if command -v gum &> /dev/null && [ "$BENTOBOX_SIMPLE_PROMPTS" != "true" ]; then
    export OMAKUB_FIRST_RUN_OPTIONAL_APPS=$(gum choose "${OPTIONAL_APPS[@]}" --no-limit --selected $DEFAULT_OPTIONAL_APPS --height 7 --header "Select optional apps" | tr ' ' '-')
  else
    # Fallback for terminals without gum support
    echo "Select optional apps (defaults: 1password)"
    echo "────────────────────────────────────────"
    echo "  [1] 1password (default)"
    echo "  [2] Barrier"
    echo "  [3] Tailscale"
    echo "  [4] WinBoat"
    echo "  [5] Sublime-Text"
    echo ""
    read -p "Enter numbers (space-separated, or Enter for default): " choices
    
    if [ -z "$choices" ]; then
      export OMAKUB_FIRST_RUN_OPTIONAL_APPS="1password"
    else
      selected=""
      for num in $choices; do
        case $num in
          1) selected="$selected 1password";;
          2) selected="$selected Barrier";;
          3) selected="$selected Tailscale";;
          4) selected="$selected WinBoat";;
          5) selected="$selected Sublime-Text";;
        esac
      done
      export OMAKUB_FIRST_RUN_OPTIONAL_APPS=$(echo $selected | tr ' ' '-')
    fi
  fi
fi

AVAILABLE_LANGUAGES=("Ruby on Rails" "Node.js" "Go" "PHP" "Python" "Elixir" "Rust" "Java")
SELECTED_LANGUAGES="Ruby on Rails","Node.js"

if command -v gum &> /dev/null && [ "$BENTOBOX_SIMPLE_PROMPTS" != "true" ]; then
  export OMAKUB_FIRST_RUN_LANGUAGES=$(gum choose "${AVAILABLE_LANGUAGES[@]}" --no-limit --selected "$SELECTED_LANGUAGES" --height 10 --header "Select programming languages")
else
  # Fallback
  echo ""
  echo "Select programming languages (defaults: Ruby on Rails, Node.js)"
  echo "────────────────────────────────────────"
  echo "  [1] Ruby on Rails (default)"
  echo "  [2] Node.js (default)"
  echo "  [3] Go"
  echo "  [4] PHP"
  echo "  [5] Python"
  echo "  [6] Elixir"
  echo "  [7] Rust"
  echo "  [8] Java"
  echo ""
  read -p "Enter numbers (space-separated, or Enter for defaults): " choices
  
  if [ -z "$choices" ]; then
    export OMAKUB_FIRST_RUN_LANGUAGES="Ruby on Rails
Node.js"
  else
    selected=""
    for num in $choices; do
      case $num in
        1) selected="$selected
Ruby on Rails";;
        2) selected="$selected
Node.js";;
        3) selected="$selected
Go";;
        4) selected="$selected
PHP";;
        5) selected="$selected
Python";;
        6) selected="$selected
Elixir";;
        7) selected="$selected
Rust";;
        8) selected="$selected
Java";;
      esac
    done
    export OMAKUB_FIRST_RUN_LANGUAGES="$selected"
  fi
fi

AVAILABLE_CONTAINERS=("Portainer" "OpenWebUI" "Ollama")
SELECTED_CONTAINERS="Portainer,OpenWebUI"

if command -v gum &> /dev/null && [ "$BENTOBOX_SIMPLE_PROMPTS" != "true" ]; then
  export OMAKUB_FIRST_RUN_CONTAINERS=$(gum choose "${AVAILABLE_CONTAINERS[@]}" --no-limit --selected "$SELECTED_CONTAINERS" --height 5 --header "Select Docker containers to deploy")
else
  # Fallback
  echo ""
  echo "Select Docker containers to deploy (defaults: Portainer, OpenWebUI)"
  echo "────────────────────────────────────────"
  echo "  [1] Portainer (default)"
  echo "  [2] OpenWebUI (default)"
  echo "  [3] Ollama"
  echo ""
  read -p "Enter numbers (space-separated, or Enter for defaults): " choices
  
  if [ -z "$choices" ]; then
    export OMAKUB_FIRST_RUN_CONTAINERS="Portainer
OpenWebUI"
  else
    selected=""
    for num in $choices; do
      case $num in
        1) selected="$selected
Portainer";;
        2) selected="$selected
OpenWebUI";;
        3) selected="$selected
Ollama";;
      esac
    done
    export OMAKUB_FIRST_RUN_CONTAINERS="$selected"
  fi
fi

