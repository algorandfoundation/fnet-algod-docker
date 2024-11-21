#!/usr/bin/env bash

cd "$(dirname "$(realpath "$0")")/.."

source utils/_common.sh

DOCKER_CLI_HINTS=false docker exec -it $DOCKER_CONTAINER_NAME /bin/cat /node/data/node.log
