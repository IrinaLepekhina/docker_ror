#!/bin/bash

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

# Function to list docker networks
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

# Function to ensure acme.json exists
ensure_acme_json() {
    local acme_path="./letsencrypt/acme.json"
    
    if [[ ! -f "$acme_path" ]]; then
        echo "acme.json does not exist. Creating it now..."
        mkdir -p "$(dirname "$acme_path")"
        touch "$acme_path"
        chmod 600 "$acme_path"
        # The chown command may not be necessary if your Docker setup doesn't need a specific user ownership.
        # chown traefik:traefik "$acme_path"
        echo "acme.json created with appropriate permissions."
    else
        echo "acme.json already exists."
    fi
}

main() {
    # ensure_acme_json
    eval $(docker-machine env do-manager-1)
    set_labels "do-manager-1"
    list_docker_networks
    deploy_and_wait "docker-stack-tr-main.yml" "traefik" 300
    deploy_and_wait "docker-stack-web.yml" "muul" 200
    deploy_and_wait "docker-stack-bot.yml" "muul" 100
}
    # --with-registry-auth --prune
main
