#!/bin/bash

# This script is responsible for managing credentials, secrets, and Docker Swarm secrets for the project.
# It performs various tasks related to Docker container management, credential generation, secret creation, and cleanup.
#
# Usage:
#   - Run the 'prepare' function to update credentials and build/push new images.
#   - Run the 'secret_management' function to manage secrets within Docker Swarm.
# Prerequisites:
#   - Docker and Docker Machine must be installed and configured.
#   - Docker Swarm must be initialized for secret management.
#   - The script targets a specific Docker Machine named "do-manager-1" by default but can be configured.

set -e

# Ensure Docker containers are running
start_containers() {
    echo "Starting Docker containers..."
    docker compose up -d
    echo "Containers started."
}

# Remove existing credentials and master key
clean_old_credentials() {
    local service_name="$1"
    echo "Removing old credentials from ${service_name}..."
    docker compose exec "${service_name}" rm -f config/credentials.yml.enc config/master.key
    echo "Old credentials removed from ${service_name}."
}

# Generate new credentials and master key
generate_credentials() {
    local service_name="$1"
    echo "Generating new credentials for ${service_name}..."
    docker compose exec "${service_name}" bash -c 'EDITOR="true" bin/rails credentials:edit'
    echo "New credentials generated for ${service_name}."
}

# Generate and locally store the secret_key_base
generate_and_store_new_secret() {
    local secret_path=$1
    local service_name=$2

    # Check if secret_path is provided
    if [ -z "$secret_path" ]; then
        echo "No path provided to store the secret!"
        exit 1
    fi

    # Check if service_name is provided
    if [ -z "$service_name" ]; then
        echo "No service name provided!"
        exit 1
    fi

    echo "Generating and storing new secret_key_base..."

    # Generate secret using Docker Compose and Rails, and store it in a variable
    SECRET_KEY_BASE=$(docker compose exec -T $service_name bin/rails secret)

    # Check if the secret was successfully generated
    if [ -z "$SECRET_KEY_BASE" ]; then
        echo "Failed to generate secret!"
        exit 1
    fi

    # Store the secret in a YML file at the provided path and set its permissions to be read-write for the owner only
    echo "secret_key_base: $SECRET_KEY_BASE" > "$secret_path"
    chmod 600 "$secret_path"

    echo "New secret_key_base generated and stored securely at: $secret_path"
}

inform_user() {
    local service_name="$1"
    echo "---------------------------------------------------------"
    echo "If you'll need to manually update the credentials with this new secret_key_base,"
    echo "consider the following steps for manual editing within your running container:"
    echo "1. Enter your running ${service_name} container:"
    echo "   docker compose exec ${service_name} /bin/bash"
    echo "2. Install vim:"
    echo "   apt-get update && apt-get install vim"
    echo "3. Edit credentials:"
    echo '   EDITOR="vim" bin/rails credentials:edit' #--environment production
    echo "4. Make your edits and save (using vim):"
    echo "   - Press Esc to ensure you are in Normal mode."
    echo "   - Type :wq and then press Enter."
    echo "5. Optionally, purge vim and clean up:"
    echo "   apt-get purge -y vim && apt-get autoremove -y && apt-get clean && rm -rf /var/lib/apt/lists/*"
    echo "---------------------------------------------------------"
}

setup_docker_machine() {
    echo "======= Setting Docker Machine Environment ======="
    eval $(docker-machine env do-manager-1)
    docker_machine_ip=$(docker-machine ip do-manager-1)
    echo "Docker Machine IP: $docker_machine_ip"
}

check_swarm_secret() {
    local secret_name="$1"

    # Ensure Docker Swarm is active
    if [ "$(docker info --format '{{.Swarm.LocalNodeState}}')" != "active" ]; then
        echo "Docker Swarm is not active. Please initialize Docker Swarm and retry."
        exit 1
    fi

    # Check if the secret exists
    if docker secret inspect "$secret_name" > /dev/null 2>&1; then
        echo "Secret [$secret_name] exists."
    else
        echo "Secret [$secret_name] does not exist."
    fi
}

delete_swarm_secret() {
    local secret_name="$1"

    # Ensure Docker Swarm is active
    if [ "$(docker info --format '{{.Swarm.LocalNodeState}}')" != "active" ]; then
        echo "Docker Swarm is not active. Please initialize Docker Swarm and retry."
        exit 1
    fi

    # Check if the secret exists
    if docker secret inspect "$secret_name" > /dev/null 2>&1; then
        docker secret rm "$secret_name"
        echo "Secret [$secret_name] has been deleted."
    else
        echo "Secret [$secret_name] does not exist."
    fi
}

create_swarm_secret() {
    local secret_name="$1"
    local master_key="$2"

    # Ensure Docker Swarm is active
    if [ "$(docker info --format '{{.Swarm.LocalNodeState}}')" != "active" ]; then
        echo "Docker Swarm is not active. Please initialize Docker Swarm and retry."
        exit 1
    fi

    # Check if the secret exists
    if docker secret inspect "$secret_name" > /dev/null 2>&1; then
        echo "Secret [$secret_name] already exists."
    else
        echo -n "$master_key" | docker secret create "$secret_name" -
        echo "Secret [$secret_name] created."
        
        # Optionally, unset master_key variable for security purposes
        unset master_key
    fi
}

# Locally updates credentialse
# build_push new images after running
prepare() {
    # start_containers
    clean_old_credentials tg_bot
    generate_credentials tg_bot
    generate_and_store_new_secret "/home/irina/.secrets/tg_bot_secret_key_base.yml" "tg_bot"
    inform_user tg_bot
    echo "======= Done ======="
}

# Managing secrets in Swarm
secret_management() {
    setup_docker_machine

    delete_swarm_secret ai_chat_master_key
    check_swarm_secret  ai_chat_master_key
    # create_swarm_secret ai_chat_master_key <master_key>

    delete_swarm_secret tg_bot_master_key
    check_swarm_secret  tg_bot_master_key
    # create_swarm_secret tg_bot_master_key <master_key>
    echo "======= Done ======="
}

# prepare
secret_management
