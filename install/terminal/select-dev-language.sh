#!/bin/bash

# Load languages from config file if it exists
CONFIG_FILE="$HOME/.bentobox-config.yaml"

if [ -f "$CONFIG_FILE" ]; then
	# Parse YAML config for languages
	languages=$(python3 -c "
import yaml
with open('$CONFIG_FILE') as f:
    config = yaml.safe_load(f)
    langs = config.get('languages', [])
    print(' '.join(langs))
" 2>/dev/null)
	
	if [ -z "$languages" ]; then
		echo "ℹ️  No languages selected in config, skipping..."
		exit 0
	fi
	echo "📦 Using languages from config: $languages"
elif [[ -v OMAKUB_FIRST_RUN_LANGUAGES ]]; then
  languages=$OMAKUB_FIRST_RUN_LANGUAGES
else
	# Only show interactive prompt if no config exists
	if command -v gum &> /dev/null; then
		AVAILABLE_LANGUAGES=("Ruby on Rails" "Node.js" "Go" "PHP" "Python" "Elixir" "Rust" "Java")
		languages=$(gum choose "${AVAILABLE_LANGUAGES[@]}" --no-limit --height 10 --header "Select programming languages")
	else
		echo "ℹ️  No config file and gum not available, skipping language selection..."
		exit 0
	fi
fi

if [[ -n "$languages" ]]; then
  for language in $languages; do
    case $language in
    Ruby)
      if [ "$SKIP_RUBY" = "true" ]; then
        echo "✓ Ruby already installed, skipping mise installation..."
      else
        mise use --global ruby@latest
        mise settings add idiomatic_version_file_enable_tools ruby
        mise x ruby -- gem install rails --no-document
      fi
      ;;
    Node.js)
      if [ "$SKIP_NODEJS" = "true" ]; then
        echo "✓ Node.js already installed, skipping mise installation..."
      else
        mise use --global node@lts
      fi
      ;;
    Go)
      mise use --global go@latest
      ;;
    PHP)
      sudo apt -y install php php-{curl,apcu,intl,mbstring,opcache,pgsql,mysql,sqlite3,redis,xml,zip} --no-install-recommends
      php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
      php composer-setup.php --quiet && sudo mv composer.phar /usr/local/bin/composer
      rm composer-setup.php
      ;;
    Python)
      if [ "$SKIP_PYTHON" = "true" ]; then
        echo "✓ Python already installed, skipping mise installation..."
      else
        mise use --global python@latest
      fi
      ;;
    Elixir)
      mise use --global erlang@latest
      mise use --global elixir@latest
      mise x elixir -- mix local.hex --force
      ;;
    Rust)
      bash -c "$(curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs)" -- -y
      ;;
    Java)
      mise use --global java@latest
      ;;
    esac
  done
fi
