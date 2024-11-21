#!/usr/bin/env bash

LOGPFX=$(basename "$0"):
cd "$(dirname "$(realpath "$0")")/.."

set -e

source utils/_common.sh

# Is container running?
RUN_STATE=$(docker inspect $DOCKER_CONTAINER_NAME 2> /dev/null | jq -r ".[]|select(.Name == \"/$DOCKER_CONTAINER_NAME\")|.State.Running")

if [[ "$RUN_STATE" != "true" ]]; then
    exit 1
fi

# Is algod booted inside container?
$GOAL_CMD node status > /dev/null 2>&1

# Give a second or two for Sync time to budge from zero
# if we are not synced
sleep 2
