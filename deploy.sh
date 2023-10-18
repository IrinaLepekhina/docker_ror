#!/bin/bash

# This script provides functions to deploy Docker stacks, set labels on Docker nodes, pull Docker images, list Docker volumes and networks,
# and wait for a specified duration.
#
# It targets a specific Docker Machine named "do-manager-1" by default but can be configured.
#
# The script offers the following functions:
# 1. set_labels(node_name): Sets the "traefik=true" label on a specified Docker node if it doesn't already have it.
# 2. list_volumes(): Lists all current Docker volumes.
# 3. list_docker_networks(): Lists all current Docker networks.
# 4. deploy_docker_stack(stack_file, stack_name): Deploys a Docker stack from a specified Compose file and stack name.
# 5. wait_with_message(duration): Sleeps for a specified duration with a message.
# 6. deploy_and_wait(stack_file, stack_name, duration): Deploys a Docker stack and waits for the specified duration.
# 7. pull_image(image): Pulls the latest version of a Docker image.
#
# Prerequisites: Docker and Docker Machine must be installed and configured.

# Function to set labels
set_labels() {
    local node_name="$1"
    local labels=$(docker node inspect "$node_name" -f '{{ .Spec.Labels }}')
    echo "Initial labels for $node_name: $labels"

    if [[ $labels != *\"traefik=true\"* ]]; then
        echo "$node_name does not have the label traefik=true. Adding it now..."
        docker node update --label-add traefik=true "$node_name"
        labels=$(docker node inspect "$node_name" -f '{{ .Spec.Labels }}')
        echo "Labels after update for $node_name: $labels"
    else
        echo "$node_name has the label traefik=true."
    fi
}

# Function to list docker volimes
list_volumes() {
    echo "======= Current Docker Volumes ======="
    docker volume ls
}

list_docker_networks() {
    echo "======= Current Docker Networks ======="
    docker network ls
}

# Function to deploy docker stack
deploy_docker_stack() {
    local stack_file="$1"
    local stack_name="$2"
    echo "Deploying docker stack from $stack_file..."
    docker stack deploy -c "$stack_file" "$stack_name"
    echo "======= Stack Deployment Complete for $stack_name ======="
}

# Function to wait with a message
wait_with_message() {
    local duration="$1"
    echo "======= waiting ... ======="
    sleep "$duration"
}

# Function to deploy and wait
deploy_and_wait() {
    local stack_file="$1"
    local stack_name="$2"
    local duration="$3"
    deploy_docker_stack "$stack_file" "$stack_name"
    wait_with_message "$duration"
}

pull_image() {
    local image="$1"
    
    echo "Pulling the latest image from $image..."
    docker pull "$image"
}

main() {
  eval $(docker-machine env do-manager-1)
  set_labels "do-manager-1"
  list_docker_networks
  list_volumes
  deploy_and_wait "docker_stack_proxy_main.yml" "traefik" 300
  pull_image "ghcr.io/irinalepekhina/ai_chat:latest"
  pull_image "ghcr.io/irinalepekhina/tg_bot:latest"
  sleep 15
  deploy_and_wait "docker_stack_ai_chat.yml" "muul" 300
  deploy_and_wait "docker_stack_tg_bot.yml" "muul" 300

  deploy_and_wait "docker_stack_tg_bot_signup.yml" "muul" 200
  deploy_and_wait "docker_stack_tg_bot_webhook.yml" "muul" 200
}

main