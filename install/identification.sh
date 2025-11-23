#!/bin/bash

# Detect if we have an interactive terminal
if [ -t 0 ] && [ -t 1 ]; then
  echo "Enter identification for git and autocomplete..."
  SYSTEM_NAME=$(getent passwd "$USER" | cut -d ':' -f 5 | cut -d ',' -f 1)
  export OMAKUB_USER_NAME=$(gum input --placeholder "Enter full name" --value "$SYSTEM_NAME" --prompt "Name> ")
  export OMAKUB_USER_EMAIL=$(gum input --placeholder "Enter email address" --prompt "Email> ")
else
  # Non-interactive mode - use sensible defaults
  echo "🤖 Non-interactive mode - using default identification"
  export OMAKUB_USER_NAME="${USER}"
  export OMAKUB_USER_EMAIL="${USER}@$(hostname)"
  echo "  → Name: $OMAKUB_USER_NAME"
  echo "  → Email: $OMAKUB_USER_EMAIL"
fi
