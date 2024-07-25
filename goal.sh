#!/usr/bin/env bash

cd "$(dirname "$(realpath "$0")")"

docker exec -it node-fnet /node/goal -d /node/data "$@"
