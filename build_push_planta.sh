#!/bin/bash

docker build -f Dockerfile.prod -t ghcr.io/irinalepekhina/planta_chat:dev --no-cache .
docker tag ghcr.io/irinalepekhina/planta_chat:dev ghcr.io/irinalepekhina/planta_chat:latest

docker push ghcr.io/irinalepekhina/planta_chat:dev
docker push ghcr.io/irinalepekhina/planta_chat:latest
