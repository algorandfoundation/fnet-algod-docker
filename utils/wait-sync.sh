#!/usr/bin/env bash

LOGPFX=$(basename "$0"):
cd "$(dirname "$(realpath "$0")")"
cd ..

source utils/_common.sh

if ! is_node_running; then
    echo "$LOGPFX: Node is not running"
    exit 1
fi

echo -n "$LOGPFX Waiting"

while is_node_syncing; do
    echo -n "."
    sleep 3
done

echo ""
echo "$LOGPFX Synced"
