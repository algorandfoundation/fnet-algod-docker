#!/usr/bin/env bash

cd "$(dirname "$(realpath "$0")")"

LOGPFX=$(basename $0)

echo $LOGPFX: Stopping node

docker compose down

echo $LOGPFX: OK
