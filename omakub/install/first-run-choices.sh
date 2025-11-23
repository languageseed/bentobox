#!/bin/bash

# Detect if we have an interactive terminal
if [ -t 0 ] && [ -t 1 ]; then
  INTERACTIVE=true
  echo "📋 Interactive mode - you can select options"
else
  INTERACTIVE=false
  echo "🤖 Non-interactive mode - using defaults"
fi

# Only ask for default desktop app choices when running Gnome
if [[ "$XDG_CURRENT_DESKTOP" == *"GNOME"* ]]; then
  OPTIONAL_APPS=("1password" "Barrier" "Tailscale")
  DEFAULT_OPTIONAL_APPS='1password'
  
  if [ "$INTERACTIVE" = true ]; then
    export OMAKUB_FIRST_RUN_OPTIONAL_APPS=$(gum choose "${OPTIONAL_APPS[@]}" --no-limit --selected $DEFAULT_OPTIONAL_APPS --height 5 --header "Select optional apps" | tr ' ' '-')
  else
    export OMAKUB_FIRST_RUN_OPTIONAL_APPS="1password"
    echo "  → Using default optional apps: 1password"
  fi
fi

AVAILABLE_LANGUAGES=("Ruby on Rails" "Node.js" "Go" "PHP" "Python" "Elixir" "Rust" "Java")
SELECTED_LANGUAGES="Ruby on Rails","Node.js"

if [ "$INTERACTIVE" = true ]; then
  export OMAKUB_FIRST_RUN_LANGUAGES=$(gum choose "${AVAILABLE_LANGUAGES[@]}" --no-limit --selected "$SELECTED_LANGUAGES" --height 10 --header "Select programming languages")
else
  export OMAKUB_FIRST_RUN_LANGUAGES="Node.js"
  echo "  → Using default language: Node.js"
fi

AVAILABLE_CONTAINERS=("Portainer" "OpenWebUI" "Ollama")
SELECTED_CONTAINERS="Portainer,OpenWebUI"

if [ "$INTERACTIVE" = true ]; then
  export OMAKUB_FIRST_RUN_CONTAINERS=$(gum choose "${AVAILABLE_CONTAINERS[@]}" --no-limit --selected "$SELECTED_CONTAINERS" --height 5 --header "Select Docker containers to deploy")
else
  export OMAKUB_FIRST_RUN_CONTAINERS=""
  echo "  → Skipping Docker containers (non-interactive)"
fi
