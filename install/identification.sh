#!/bin/bash

echo "Enter identification for git and autocomplete..."
SYSTEM_NAME=$(getent passwd "$USER" | cut -d ':' -f 5 | cut -d ',' -f 1)

if command -v gum &> /dev/null && [ "$BENTOBOX_SIMPLE_PROMPTS" != "true" ]; then
  export OMAKUB_USER_NAME=$(gum input --placeholder "Enter full name" --value "$SYSTEM_NAME" --prompt "Name> ")
  export OMAKUB_USER_EMAIL=$(gum input --placeholder "Enter email address" --prompt "Email> ")
else
  # Fallback to simple read
  if [ -n "$SYSTEM_NAME" ]; then
    read -p "Full name [$SYSTEM_NAME]: " user_name
    export OMAKUB_USER_NAME="${user_name:-$SYSTEM_NAME}"
  else
    read -p "Full name: " user_name
    export OMAKUB_USER_NAME="$user_name"
  fi
  
  read -p "Email address: " user_email
  export OMAKUB_USER_EMAIL="$user_email"
fi

