#!/bin/bash

MACHINE_NAME="do-manager-1"
MACHINE_IP=$(docker-machine ip $MACHINE_NAME)

echo "Targeting Docker Machine: $MACHINE_NAME"
echo "Targeting Machine IP: $MACHINE_IP"

# SSH into the docker machine and run the cleanup commands
docker-machine ssh $MACHINE_NAME << 'ENDSSH'
# Check if node is part of a Swarm
    IS_PART_OF_SWARM=$(docker info --format '{{.Swarm.LocalNodeState}}')
    
    if [ "$IS_PART_OF_SWARM" == "active" ]; then
        # Check if node is a Swarm manager
        IS_MANAGER=$(docker info --format '{{.Swarm.ControlAvailable}}')
        
        if [ "$IS_MANAGER" == "true" ]; then
            echo "Node is a Swarm manager. Leaving the Swarm..."
            
            # Demote if there are other managers
            OTHER_MANAGERS=$(docker node ls --filter "role=manager" -q | wc -l)
            if [ "$OTHER_MANAGERS" -gt 1 ]; then
                NODE_ID=$(docker info --format '{{.Swarm.NodeID}}')
                docker node demote $NODE_ID
            fi
            
            # Leave the Swarm
            docker swarm leave --force
        else
            echo "Node is a Swarm worker. Leaving the Swarm..."
            docker swarm leave
        fi
        sleep 5  # Allow for node to fully leave the Swarm
    fi

# List and remove any remaining Docker Swarm services
    SERVICES=$(docker service ls -q)
    if [ ! -z "$SERVICES" ]; then
        for SERVICE in $SERVICES; do
            docker service rm $SERVICE
        done
        sleep 5  # Give Docker some time to remove the services
    fi

# Remove the Stack
    docker stack rm muul
    sleep 5  # Allow for stack resources to be freed
    # Remove the Stack
    docker stack rm traefik
    sleep 5  # Allow for stack resources to be freed

# Remove all containers
    CONTAINERS=$(docker ps -aq)
    if [ ! -z "$CONTAINERS" ]; then
        docker rm -f $CONTAINERS
    fi

# Remove all volumes
    VOLUMES=$(docker volume ls -q)
    if [ ! -z "$VOLUMES" ]; then
        docker volume rm $VOLUMES
    fi

# Remove all networks (excluding predefined ones)
    NETWORKS=$(docker network ls --filter "type=custom" -q)
    if [ ! -z "$NETWORKS" ]; then
        docker network rm $NETWORKS
    fi

# Remove all images
    IMAGES=$(docker images -q)
    if [ ! -z "$IMAGES" ]; then
        docker rmi -f $IMAGES
    fi

    # Clean up dangling resources
    docker system prune -a --volumes -f
ENDSSH
