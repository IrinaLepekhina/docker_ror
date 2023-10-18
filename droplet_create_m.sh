#!/bin/bash

# This script creates a Docker Swarm Manager Node on DigitalOcean.
# Prerequisites:
#   - Docker Machine and 'doctl' command-line tools must be installed.
#   - You need a valid DigitalOcean access token set in the DIGITAL_OCEAN_TOKEN environment variable.

NUM_WORKERS=2
REGION=ams3
SIZE=s-1vcpu-1gb
IMAGE=ubuntu-20-04-x64

# Create a Docker Swarm Manager Node
docker-machine create \
  --driver digitalocean \
  --digitalocean-access-token $DIGITAL_OCEAN_TOKEN \
  --digitalocean-region $REGION \
  --digitalocean-size $SIZE \
  --digitalocean-image $IMAGE \
  --swarm \
  --swarm-master \
  do-manager-1

# Get the external IP address of the manager node
MANAGER_EXTERNAL_IP=$(docker-machine ip do-manager-1)

# Initialize Docker Swarm on the Manager node
docker-machine ssh do-manager-1 "docker swarm init --advertise-addr $MANAGER_EXTERNAL_IP"