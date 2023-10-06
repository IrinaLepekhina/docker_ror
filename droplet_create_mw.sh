#!/bin/bash

NUM_WORKERS=2
REGION=ams3
SIZE=s-1vcpu-1gb
IMAGE=ubuntu-20-04-x64

# Create and Initialize the Docker Swarm Manager Node
create_manager_node() {
  docker-machine create \
    --driver digitalocean \
    --digitalocean-access-token $DIGITAL_OCEAN_TOKEN \
    --digitalocean-region $REGION \
    --digitalocean-size $SIZE \
    --digitalocean-image $IMAGE \
    --swarm \
    --swarm-master \
    do-manager-1

  MANAGER_EXTERNAL_IP=$(docker-machine ip do-manager-1)
  docker-machine ssh do-manager-1 "docker swarm init --advertise-addr $MANAGER_EXTERNAL_IP"
  docker-machine ssh do-manager-1 "docker node update --label-add traefik=true do-manager-1"
}

# Create Worker Nodes and Join them to the Swarm
create_worker_nodes() {
  SWARM_TOKEN=$(docker-machine ssh do-manager-1 "docker swarm join-token -q worker")

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
}

# Main Execution
create_manager_node
create_worker_nodes

echo "Manager IP: $MANAGER_EXTERNAL_IP"
echo "Swarm setup complete!"
