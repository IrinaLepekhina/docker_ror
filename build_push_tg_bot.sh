#!/bin/bash

# This script builds a Docker image for the tg_bot service, tags it with the 'dev' and 'latest' tags,
# and pushes it to the specified container registry.

docker build -f Dockerfile.prod -t ghcr.io/irinalepekhina/tg_bot:dev --no-cache .
docker tag ghcr.io/irinalepekhina/tg_bot:dev ghcr.io/irinalepekhina/tg_bot:latest

docker push ghcr.io/irinalepekhina/tg_bot:dev
docker push ghcr.io/irinalepekhina/tg_bot:latest
