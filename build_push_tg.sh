#!/bin/bash

docker build -f Dockerfile.prod -t ghcr.io/irinalepekhina/tg_bot:dev --no-cache .
docker tag ghcr.io/irinalepekhina/tg_bot:dev ghcr.io/irinalepekhina/tg_bot:latest

docker push ghcr.io/irinalepekhina/tg_bot:dev
docker push ghcr.io/irinalepekhina/tg_bot:latest
