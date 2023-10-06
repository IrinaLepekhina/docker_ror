#!/bin/bash

# List all machines managed by docker-machine
machines=$(docker-machine ls -q)

# Loop through the machine names and start each one
for machine in $machines; do
  echo "Powering up machine: $machine"
  docker-machine start "$machine"
done

echo "Power on process initiated for all machines"