#!/bin/bash

# Check if Docker should be skipped (already installed)
if [ "$SKIP_DOCKER" = "true" ]; then
    echo "✓ Docker already installed, skipping..."
    exit 0
fi

# Detect OS for Docker repository
. /etc/os-release

# Determine Docker repository base URL
if [[ "$ID" == "debian" || "$ID" == "raspbian" ]]; then
    DOCKER_REPO_URL="https://download.docker.com/linux/debian"
    DOCKER_GPG_URL="https://download.docker.com/linux/debian/gpg"
elif [[ "$ID" == "ubuntu" || "$ID" == "pop" || "$ID" == "elementary" || "$ID" == "mint" || "$ID" == "neon" ]]; then
    DOCKER_REPO_URL="https://download.docker.com/linux/ubuntu"
    DOCKER_GPG_URL="https://download.docker.com/linux/ubuntu/gpg"
    # For Ubuntu derivatives, use Ubuntu codename
    if [[ "$ID" != "ubuntu" ]]; then
        VERSION_CODENAME=$(grep UBUNTU_CODENAME /etc/os-release | cut -d= -f2)
    fi
else
    echo "❌ Unsupported distribution for Docker installation: $ID"
    exit 1
fi

# Add the official Docker repo
if [ ! -f /etc/apt/sources.list.d/docker.list ]; then
    echo "📦 Adding Docker repository for $ID..."
    [ -f /etc/apt/keyrings/docker.asc ] && sudo rm /etc/apt/keyrings/docker.asc
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo wget -qO /etc/apt/keyrings/docker.asc "$DOCKER_GPG_URL"
    sudo chmod a+r /etc/apt/keyrings/docker.asc
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] $DOCKER_REPO_URL $VERSION_CODENAME stable" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
fi

# Install Docker engine and standard plugins
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-ce-rootless-extras

# Give this user privileged Docker access
sudo usermod -aG docker ${USER}

# Limit log size to avoid running out of disk
echo '{"log-driver":"json-file","log-opts":{"max-size":"10m","max-file":"5"}}' | sudo tee /etc/docker/daemon.json
