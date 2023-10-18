#!/bin/bash

# This script runs a series of other scripts to manage Docker Machine instances, 
# including cleaning up, joining a Docker Swarm, deploying services,
# and then waiting before collecting statistics.

./droplet_clean.sh
./droplet_join_m.sh
./deploy.sh

echo "All scripts executed successfully!"

echo "waiting for stat ..."
sleep 60

./stat.sh