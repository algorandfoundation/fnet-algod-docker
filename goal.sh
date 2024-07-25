#!/usr/bin/env bash

cd "$(dirname "$(realpath "$0")")"

DOCKER_CLI_HINTS=false docker exec -it node-fnet /node/goal -d /node/data "$@"
