#!/bin/bash

MANAGER_EXTERNAL_IP=$(docker-machine ip do-manager-1)

# Initialize Docker Swarm on the Manager node
docker-machine ssh do-manager-1 "docker swarm init --advertise-addr $MANAGER_EXTERNAL_IP"

echo "Initialized Docker Swarm on the Manager node"
echo "MANAGER_EXTERNAL_IP=$MANAGER_EXTERNAL_IP"
