#!/bin/bash

# This script provides functions to manage Docker containers on a specific Docker Machine.
# It targets the Docker Machine named "do-manager-1" by default but can be configured.
#
# The script offers the following functions:
# 1. setup_docker_machine(): Sets up the Docker Machine environment and displays the machine's IP.
# 2. list_running_containers(): Lists all currently running Docker containers.
# 3. enter_container(service_name): Allows you to enter a specified Docker container by its service name.
# 4. execute_command(command): Executes a command inside a fresh instance of a specified container.
#    The container is identified by the service name "muul_ai_chat," which can be customized.
#
# Prerequisites: Docker and Docker Machine must be installed and configured.

# Function to setup Docker Machine
setup_docker_machine() {
  echo "======= Setting Docker Machine Environment ======="
  eval $(docker-machine env do-manager-1)
  docker_machine_ip=$(docker-machine ip do-manager-1)
  echo "Docker Machine IP: $docker_machine_ip"
}

# Function to list all running containers
list_running_containers() {
    echo "======= Listing All Running Containers ======="
    docker ps
}

# Function to enter the muul_ai_chat container
enter_container() {
    local service_name="$1"
    
    echo "======= Entering the $service_name Container ======="
    
    local container_id=$(docker ps --filter "name=$service_name" --format "{{.ID}}" | head -n 1)
    
    if [ -z "$container_id" ]; then
        echo "$service_name container is not running or not found!"
        exit 1
    fi

    echo "Entering the container with ID: $container_id"
    
    # Executing /bin/sh for the container
    docker exec -it "$container_id" /bin/sh
}

execute_command() {
    local command=$1

    if [ -z "$command" ]; then
        echo "No command provided to execute_command function!"
        exit 1
    fi

    # Identify the ID of the muul_ai_chat container
    local container_id=$(docker ps --filter "name=muul_ai_chat" --format "{{.ID}}" | head -n 1)

    if [ -z "$container_id" ]; then
        echo "ai_chat container for service muul_ai_chat is not running or not found!"
        exit 1
    fi

    # Identify the image used by muul_ai_chat container
    local image=$(docker inspect $container_id --format '{{.Config.Image}}')

    if [ -z "$image" ]; then
        echo "Image for the muul_ai_chat container cannot be determined!"
        exit 1
    fi

    echo "Executing 'bundle exec $command' in a fresh instance of the muul_ai_chat container image..."
    
    # Start a fresh container with the same image and execute the command
    docker run --rm -it $image /bin/sh -c "bundle exec $command"
}

main() {
    setup_docker_machine
    list_running_containers
    enter_container muul_ai_chat
}

main