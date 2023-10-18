#!/bin/bash

# This script lists and starts all Docker machines managed by docker-machine.
# It iterates through the list of machines and powers them on one by one.
#
# Usage:
#   - Run this script to start all Docker machines managed by docker-machine.
# Prerequisites:
#   - Docker Machine must be installed and configured on the host machine.

# List all machines managed by docker-machine
machines=$(docker-machine ls -q)

# Loop through the machine names and start each one
for machine in $machines; do
  echo "Powering up machine: $machine"
  docker-machine start "$machine"
done

echo "Power on process initiated for all machines"