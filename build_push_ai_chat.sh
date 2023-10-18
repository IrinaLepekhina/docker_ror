#!/bin/bash

# This script builds a Docker image for the ai_chat service, tags it with the 'dev' and 'latest' tags,
# and pushes it to the specified container registry.

docker build -f Dockerfile.prod -t ghcr.io/irinalepekhina/ai_chat:dev --no-cache .
docker tag ghcr.io/irinalepekhina/ai_chat:dev ghcr.io/irinalepekhina/ai_chat:latest

docker push ghcr.io/irinalepekhina/ai_chat:dev
docker push ghcr.io/irinalepekhina/ai_chat:latest
