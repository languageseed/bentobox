#!/bin/bash

# Install default containers
if [[ -v OMAKUB_FIRST_RUN_CONTAINERS ]]; then
	containers=$OMAKUB_FIRST_RUN_CONTAINERS
else
	AVAILABLE_CONTAINERS=("Portainer" "OpenWebUI" "Ollama")
	containers=$(gum choose "${AVAILABLE_CONTAINERS[@]}" --no-limit --height 5 --header "Select containers to deploy")
fi

if [[ -n "$containers" ]]; then
	for container in $containers; do
		case $container in
		Portainer)
			echo "Deploying Portainer (Docker Management UI)..."
			sudo docker volume create portainer_data
			sudo docker run -d \
				--restart unless-stopped \
				-p "127.0.0.1:9000:9000" \
				-p "127.0.0.1:9443:9443" \
				--name=portainer \
				-v /var/run/docker.sock:/var/run/docker.sock \
				-v portainer_data:/data \
				portainer/portainer-ce:latest
			echo "✅ Portainer installed! Access at: http://localhost:9000 or https://localhost:9443"
			;;
		OpenWebUI)
			echo "Deploying OpenWebUI (AI Chat Interface)..."
			sudo docker volume create open-webui
			sudo docker run -d \
				--restart unless-stopped \
				-p "127.0.0.1:3000:8080" \
				--name=open-webui \
				-v open-webui:/app/backend/data \
				-e OLLAMA_BASE_URL=http://host.docker.internal:11434 \
				--add-host=host.docker.internal:host-gateway \
				ghcr.io/open-webui/open-webui:main
			echo "✅ OpenWebUI installed! Access at: http://localhost:3000"
			;;
		Ollama)
			echo "Deploying Ollama (Local LLM Server)..."
			sudo docker volume create ollama
			sudo docker run -d \
				--restart unless-stopped \
				-p "127.0.0.1:11434:11434" \
				--name=ollama \
				-v ollama:/root/.ollama \
				ollama/ollama:latest
			echo "✅ Ollama installed! Running at: http://localhost:11434"
			echo "   Run 'docker exec -it ollama ollama pull llama3.2' to download a model"
			;;
		esac
	done
fi
