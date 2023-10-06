#!/bin/bash

NUM_WORKERS=2
REGION=ams3
SIZE=s-1vcpu-1gb
IMAGE=ubuntu-20-04-x64

# Get the external IP address of the manager node
MANAGER_EXTERNAL_IP=$(docker-machine ip do-manager-1)

# Initialize Docker Swarm on the Manager node
docker-machine ssh do-manager-1 "docker swarm init --advertise-addr $MANAGER_EXTERNAL_IP"

# Get the Swarm token
SWARM_TOKEN=$(docker-machine ssh do-manager-1 "docker swarm join-token -q worker")

echo "SWARM_TOKEN=$SWARM_TOKEN"
echo "MANAGER_EXTERNAL_IP=$MANAGER_EXTERNAL_IP"

for i in $(seq 1 $NUM_WORKERS); do
  docker-machine create \
    --driver digitalocean \
    --digitalocean-access-token $DIGITAL_OCEAN_TOKEN \
    --digitalocean-region $REGION \
    --digitalocean-size $SIZE \
    --digitalocean-image $IMAGE \
    --swarm \
    do-worker-$i

  docker-machine ssh do-worker-$i "docker swarm join --token $SWARM_TOKEN $MANAGER_EXTERNAL_IP:2377"
done
