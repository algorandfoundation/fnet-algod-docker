#!/usr/bin/env bash

# Relies on nodely, trusting the catchpoint

LOGPFX=$(basename "$0"):
cd "$(dirname "$(realpath "$0")")"
cd ..

set -e

source utils/_common.sh

if ! is_node_syncing; then
    echo "$LOGPFX Node seems in sync, aborting catchup"
    exit 0
fi

LAST_CP=$(curl -s https://fnet-api.4160.nodely.io/v2/status | jq -r '.["last-catchpoint"] // ""')

if [[ "$LAST_CP" != "" ]]; then
    echo "$LOGPFX Catching up..."
    ./goal.sh node catchup "$LAST_CP"
    echo "$LOGPFX Waiting for sync"
    ./utils/wait-sync.sh
else
    echo "$LOGPFX Catchpoint not available. Syncing should be reasonably quick"
fi
