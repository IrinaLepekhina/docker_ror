#!/bin/bash

# This script is responsible for removing Docker images, containers, networks, and volumes that are no longer in use.
#
# Usage:
#   - Modify the 'images' and 'volumes' arrays to specify the images and volumes to be checked and removed.
#   - Run the script to perform the cleanup.
# Prerequisites:
#   - Docker must be installed and configured on the host machine.

set -e

# List of images to check and remove
images=(
  "ghcr.io/irinalepekhina/tg_bot:dev"
  "ghcr.io/irinalepekhina/tg_bot:latest"
  "ghcr.io/irinalepekhina/ai_chat:dev"
  "ghcr.io/irinalepekhina/ai_chat:latest"
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
  "db_data_ai_chat"
  "db_data_tg_bot"
)

for volume in "${volumes[@]}"; do
  if docker volume ls -q | grep -q "^${volume}$"; then
    echo "Removing volume: $volume"
    docker volume rm "$volume"
  else
    echo "Volume $volume does not exist. Skipping."
  fi
done
