#!/bin/bash

# Please be aware of the implications (i.e., Docker daemon restart and potential container stops).
docker-machine regenerate-certs do-manager-1

docker-machine restart do-manager-1