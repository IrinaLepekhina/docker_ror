#!/bin/bash

# List all machines managed by docker-machine
machines=$(docker-machine ls -q)

# Loop through the machine names and stop each one
for machine in $machines; do
  echo "Shutting down machine: $machine"
  docker-machine stop "$machine"
done

echo "Shutdown process initiated for all machines"