#!/usr/bin/env bash

LOGPFX=$(basename "$0"):
cd "$(dirname "$(realpath "$0")")/.."

set -e

source utils/_common.sh


RUN_STATE=$(docker inspect node-fnet 2> /dev/null | jq -r '.[]|select(.Name == "/node-fnet")|.State.Running')
IS_RUNNING=$([[ "$RUN_STATE" = "true" ]])
exit $IS_RUNNING
