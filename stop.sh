#!/usr/bin/env bash

cd "$(dirname "$(realpath "$0")")"

echo $0: Stopping node

docker compose down

echo $0: OK
