#!/bin/bash

# Set OMAKUB_PATH if not already set
if [[ -z "$OMAKUB_PATH" ]]; then
	export OMAKUB_PATH="$HOME/.local/share/omakub"
fi

if [[ -v OMAKUB_FIRST_RUN_OPTIONAL_APPS ]]; then
	apps=$OMAKUB_FIRST_RUN_OPTIONAL_APPS

	if [[ -n "$apps" ]]; then
		for app in $apps; do
			source "$OMAKUB_PATH/install/desktop/optional/app-${app,,}.sh"
		done
	fi
fi
