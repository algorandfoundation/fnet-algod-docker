#!/usr/bin/env bash

cd "$(dirname "$(realpath "$0")")"

source utils/_common.sh

DOCKER_CLI_HINTS=false exec docker exec -i $DOCKER_CONTAINER_NAME /node/goal -d /node/data "$@"
