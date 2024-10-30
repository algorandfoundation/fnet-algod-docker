#!/usr/bin/env bash

DOCKER_CLI_HINTS=false docker exec -it node-fnet /bin/cat /node/data/node.log
