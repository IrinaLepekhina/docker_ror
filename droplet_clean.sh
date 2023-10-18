#!/bin/bash

# This script is designed to clean up and reset Docker resources on a specified Docker Machine.
#
# It targets the Docker Machine named "do-manager-1" by default, but you can change the MACHINE_NAME variable.
# The script performs the following operations:
# 1. Leaves the Docker Swarm (if the node is part of one).
# 2. Removes Docker services.
# 3. Removes Docker stacks.
# 4. Removes Docker containers.
# 5. Removes Docker volumes (except for the "traefik_tls_certs" volume).
# 6. Removes Docker networks.
# 7. Removes Docker images.
# 8. Performs a complete system cleanup, including volumes and unused images.
#
# Prerequisites: Docker and Docker Machine must be installed and configured.

MACHINE_NAME="do-manager-1"

echo "Targeting Docker Machine: $MACHINE_NAME"
echo "Targeting Machine IP: $(docker-machine ip $MACHINE_NAME)"

sleep_and_print() {
    sleep 5
    echo "Waiting for resources to be freed..."
}

leave_swarm() {
    IS_PART_OF_SWARM=$(docker info --format '{{.Swarm.LocalNodeState}}')
    if [ "$IS_PART_OF_SWARM" == "active" ]; then
        IS_MANAGER=$(docker info --format '{{.Swarm.ControlAvailable}}')
        if [ "$IS_MANAGER" == "true" ]; then
            echo "Node is a Swarm manager. Leaving the Swarm..."
            OTHER_MANAGERS=$(docker node ls --filter "role=manager" -q | wc -l)
            if [ "$OTHER_MANAGERS" -gt 1 ]; then
                NODE_ID=$(docker info --format '{{.Swarm.NodeID}}')
                docker node demote $NODE_ID
            fi
            docker swarm leave --force
        else
            echo "Node is a Swarm worker. Leaving the Swarm..."
            docker swarm leave
        fi
        sleep_and_print
    fi
}

remove_services() {
    SERVICES=$(docker service ls -q)
    if [ ! -z "$SERVICES" ]; then
        docker service rm $SERVICES
        sleep_and_print
    fi
}

remove_stacks() {
    for stack in muul traefik; do
        docker stack rm $stack
        sleep_and_print
    done
}

remove_containers() {
    CONTAINERS=$(docker ps -aq)
    if [ ! -z "$CONTAINERS" ]; then
        docker rm -f $CONTAINERS
    fi
}

remove_volumes_except() {
    local exception=$1
    VOLUMES=$(docker volume ls -q | grep -v "^$exception$")
    docker volume rm $VOLUMES
}

remove_networks() {
    NETWORKS=$(docker network ls --filter "type=custom" -q)
    if [ ! -z "$NETWORKS" ]; then
        docker network rm $NETWORKS
    fi
}

remove_images() {
    IMAGES=$(docker images -q)
    if [ ! -z "$IMAGES" ]; then
        docker rmi -f $IMAGES
    fi
}

clean_system() {
    docker system prune -a --volumes -f
}

main() {
    eval $(docker-machine env $MACHINE_NAME)
    leave_swarm
    remove_services
    remove_stacks
    remove_containers
    remove_volumes_except "traefik_tls_certs"
    remove_networks
    remove_images
    eval $(docker-machine env -u) # Reset the Docker environment back to the local machine
}

main
