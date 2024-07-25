#!/usr/bin/env bash

cd "$(dirname "$(realpath "$0")")"

docker exec -it node-fnet /bin/ash
