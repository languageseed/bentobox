#!/bin/bash

# Load containers from config file if it exists
CONFIG_FILE="$HOME/.bentobox-config.yaml"

if [ -f "$CONFIG_FILE" ]; then
	# Parse YAML config for containers
	containers=$(python3 -c "
import yaml
with open('$CONFIG_FILE') as f:
    config = yaml.safe_load(f)
    containers = config.get('containers', [])
    print(' '.join(containers))
" 2>/dev/null)
	
	if [ -z "$containers" ]; then
		echo "ℹ️  No containers selected in config, skipping..."
		exit 0
	fi
	echo "📦 Using containers from config: $containers"
elif [[ -v OMAKUB_FIRST_RUN_CONTAINERS ]]; then
	containers=$OMAKUB_FIRST_RUN_CONTAINERS
else
	# Only show interactive prompt if no config exists
	if command -v gum &> /dev/null; then
		AVAILABLE_CONTAINERS=("Portainer" "OpenWebUI" "Ollama")
		containers=$(gum choose "${AVAILABLE_CONTAINERS[@]}" --no-limit --height 5 --header "Select containers to deploy")
	else
		echo "ℹ️  No config file and gum not available, skipping container selection..."
		exit 0
	fi
fi

if [[ -n "$containers" ]]; then
	for container in $containers; do
		case $container in
		Portainer)
			if [ "$SKIP_PORTAINER" = "true" ]; then
				echo "✓ Portainer already running, skipping..."
			else
				# Check if container already exists (even if not running)
				if docker ps -a --format '{{.Names}}' 2>/dev/null | grep -q "^portainer$"; then
					echo "✓ Portainer container already exists, skipping..."
				else
					echo "Deploying Portainer (Docker Management UI)..."
					sudo docker volume create portainer_data 2>/dev/null || true
					sudo docker run -d \
						--restart unless-stopped \
						-p "127.0.0.1:9000:9000" \
						-p "127.0.0.1:9443:9443" \
						--name=portainer \
						-v /var/run/docker.sock:/var/run/docker.sock \
						-v portainer_data:/data \
						portainer/portainer-ce:latest
					echo "✅ Portainer installed! Access at: http://localhost:9000 or https://localhost:9443"
				fi
			fi
			;;
		OpenWebUI)
			if [ "$SKIP_OPENWEBUI" = "true" ]; then
				echo "✓ OpenWebUI already running, skipping..."
			else
				# Check if container already exists (even if not running)
				if docker ps -a --format '{{.Names}}' 2>/dev/null | grep -q "^open-webui$"; then
					echo "✓ OpenWebUI container already exists, skipping..."
				else
					echo "Deploying OpenWebUI (AI Chat Interface)..."
					sudo docker volume create open-webui 2>/dev/null || true
					sudo docker run -d \
						--restart unless-stopped \
						-p "127.0.0.1:3000:8080" \
						--name=open-webui \
						-v open-webui:/app/backend/data \
						-e OLLAMA_BASE_URL=http://host.docker.internal:11434 \
						--add-host=host.docker.internal:host-gateway \
						ghcr.io/open-webui/open-webui:main
					echo "✅ OpenWebUI installed! Access at: http://localhost:3000"
				fi
			fi
			;;
		Ollama)
			if [ "$SKIP_OLLAMA" = "true" ]; then
				echo "✓ Ollama already running, skipping..."
			else
				# Check if container already exists (even if not running)
				if docker ps -a --format '{{.Names}}' 2>/dev/null | grep -q "^ollama$"; then
					echo "✓ Ollama container already exists, skipping..."
				else
					echo "Deploying Ollama (Local LLM Server)..."
					sudo docker volume create ollama 2>/dev/null || true
					sudo docker run -d \
						--restart unless-stopped \
						-p "127.0.0.1:11434:11434" \
						--name=ollama \
						-v ollama:/root/.ollama \
						ollama/ollama:latest
					echo "✅ Ollama installed! Running at: http://localhost:11434"
					echo "   Run 'docker exec -it ollama ollama pull llama3.2' to download a model"
				fi
			fi
			;;
		esac
	done
fi
