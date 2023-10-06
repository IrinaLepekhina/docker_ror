#!/bin/bash

# List of images to check and remove
images=(
  "ghcr.io/irinalepekhina/tg_bot:dev"
  "ghcr.io/irinalepekhina/tg_bot:latest"
  "ghcr.io/irinalepekhina/planta_chat:dev"
  "ghcr.io/irinalepekhina/planta_chat:latest"
)

for image in "${images[@]}"; do
  if docker image ls -q "$image" | grep -q -v '^$'; then
    echo "Removing image: $image"
    docker image rm "$image"
  else
    echo "Image $image does not exist. Skipping."
  fi
done

docker container prune -f
docker image prune -f
docker network prune -f
docker volume prune -f

# List of volumes to check and remove
volumes=(
  "docker_ror_db_data_web" 
  "docker_ror_db_data_bot" 
)

for volume in "${volumes[@]}"; do
  if docker volume ls -q | grep -q "^${volume}$"; then
    echo "Removing volume: $volume"
    docker volume rm "$volume"
  else
    echo "Volume $volume does not exist. Skipping."
  fi
done
