#!/bin/bash

./droplet_clean.sh
./droplet_join_m.sh
./deploy.sh

echo "All scripts executed successfully!"

echo "waiting for stat ..."
sleep 60

./stat.sh