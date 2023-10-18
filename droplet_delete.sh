#!/bin/bash

# This script lists all DigitalOcean Droplets and deletes them one by one.
#
# Usage:
#   - Ensure you have the 'doctl' command-line tool installed and configured with your DigitalOcean account.
#   - Run this script to initiate the deletion process for all Droplets.
# Warning:
#   - This script will irreversibly delete all Droplets associated with your account.
#   - Use with caution and ensure you have backups or snapshots if needed.

# List all Droplets and extract their IDs
droplet_ids=$(doctl compute droplet list --no-header --format ID)

# Loop through the IDs and delete each Droplet
for droplet_id in $droplet_ids; do
  echo "Deleting Droplet with ID: $droplet_id"
  doctl compute droplet delete --force "$droplet_id"
done

echo "Deletion process initiated for all Droplets"
