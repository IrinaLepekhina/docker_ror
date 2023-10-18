#!/bin/bash

# This script stops all Docker Machine instances managed on the host machine.
#
# Usage:
#   - Run this script to shut down all Docker Machine instances.
#
# Prerequisites:
#   - Docker Machine must be installed and configured on the host machine.

# List all machines managed by docker-machine
machines=$(docker-machine ls -q)

# Loop through the machine names and stop each one
for machine in $machines; do
  echo "Shutting down machine: $machine"
  docker-machine stop "$machine"
done

echo "Shutdown process initiated for all machines"
