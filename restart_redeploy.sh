#!/bin/bash

# This script runs a series of other scripts to manage Docker Machine instances.
#
# Usage:
#   - Run this script to execute the following actions sequentially:
#     1. Shut down Docker Machine instances.
#     2. Clean up resources.
#     3. Start Docker Machine instances.
#     4. Redeploy Docker containers.
#
# Prerequisites:
#   - Docker Machine must be installed and configured on the host machine.

./droplet_clean.sh
./droplet_down.sh
./droplet_up.sh
./redeploy.sh