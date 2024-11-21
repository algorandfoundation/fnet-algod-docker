#!/usr/bin/env bash

# Starts fast catchup

LOGPFX=$(basename "$0"):
cd "$(dirname "$(realpath "$0")")/.."

source utils/_common.sh

DOCKER_CLI_HINTS=false docker exec -it $DOCKER_CONTAINER_NAME /usr/bin/tail -f /node/data/node.log
