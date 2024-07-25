#!/usr/bin/env bash

cd "$(dirname "$(realpath "$0")")"

flags="-it"

# test if stdin has anything; remove the -t flag if so
if read -t 0; then
    flags="-i"
fi

DOCKER_CLI_HINTS=false exec docker exec $flags node-fnet /node/goal -d /node/data "$@"
