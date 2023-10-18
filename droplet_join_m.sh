#!/bin/bash

# This script initializes a Docker Swarm on the Manager node named "do-manager-1."
# It obtains the external IP address of the Manager node and uses it as the advertise address.
#
# Usage:
#   - Run this script to initialize a Docker Swarm on the Manager node.
#
# Prerequisites:
#   - Docker Machine must be installed and configured on the host machine.
#   - The Docker Machine "do-manager-1" should already be created.

# Get the external IP address of the Manager node
MANAGER_EXTERNAL_IP=$(docker-machine ip do-manager-1)

# Initialize Docker Swarm on the Manager node using the external IP address as the advertise address
docker-machine ssh do-manager-1 "docker swarm init --advertise-addr $MANAGER_EXTERNAL_IP"

echo "Initialized Docker Swarm on the Manager node"
echo "MANAGER_EXTERNAL_IP=$MANAGER_EXTERNAL_IP"
