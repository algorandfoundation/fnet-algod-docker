#!/usr/bin/env bash

DOCKER_CLI_HINTS=false docker exec -it node-fnet /usr/bin/tail -f /node/data/node.log
