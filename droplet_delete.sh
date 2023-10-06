#!/bin/bash

# List all Droplets and extract their IDs
droplet_ids=$(doctl compute droplet list --no-header --format ID)

# Loop through the IDs and delete each Droplet
for droplet_id in $droplet_ids; do
  echo "Deleting Droplet with ID: $droplet_id"
  doctl compute droplet delete --force "$droplet_id"
done

echo "Deletion process initiated for all Droplets"
