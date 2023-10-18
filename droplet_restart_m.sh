#!/bin/bash

# This script regenerates the TLS certificates for a Docker Machine named "do-manager-1" 
# and then restarts the Docker Machine.
#
# Please be aware of the implications, including a Docker daemon restart and potential 
# container stops when regenerating certificates.
#
# Usage:
#   - Run this script to regenerate TLS certificates and restart the Docker Machine.
# Prerequisites:
#   - Docker Machine must be installed and configured on the host machine.
#   - The Docker Machine "do-manager-1" should already be created.

# Regenerate TLS certificates for the Docker Machine
docker-machine regenerate-certs do-manager-1

# Restart the Docker Machine
docker-machine restart do-manager-1
