#!/bin/bash

# Only ask for default desktop app choices when running Gnome
if [[ "$XDG_CURRENT_DESKTOP" == *"GNOME"* ]]; then
  OPTIONAL_APPS=("1password" "Barrier" "Tailscale")
  DEFAULT_OPTIONAL_APPS='1password'
  export OMAKUB_FIRST_RUN_OPTIONAL_APPS=$(gum choose "${OPTIONAL_APPS[@]}" --no-limit --selected $DEFAULT_OPTIONAL_APPS --height 5 --header "Select optional apps" | tr ' ' '-')
fi

AVAILABLE_LANGUAGES=("Ruby on Rails" "Node.js" "Go" "PHP" "Python" "Elixir" "Rust" "Java")
SELECTED_LANGUAGES="Ruby on Rails","Node.js"
export OMAKUB_FIRST_RUN_LANGUAGES=$(gum choose "${AVAILABLE_LANGUAGES[@]}" --no-limit --selected "$SELECTED_LANGUAGES" --height 10 --header "Select programming languages")

AVAILABLE_CONTAINERS=("Portainer" "OpenWebUI" "Ollama")
SELECTED_CONTAINERS="Portainer,OpenWebUI"
export OMAKUB_FIRST_RUN_CONTAINERS=$(gum choose "${AVAILABLE_CONTAINERS[@]}" --no-limit --selected "$SELECTED_CONTAINERS" --height 5 --header "Select Docker containers to deploy")
