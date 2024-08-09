#!/usr/bin/env bash

cd "$(dirname "$(realpath "$0")")"

DOCKER_CLI_HINTS=false exec docker exec -i node-fnet /node/goal -d /node/data "$@"
