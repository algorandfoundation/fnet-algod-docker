#!/usr/bin/env bash

set -e

LOGPFX=$(basename "$0"):
cd "$(dirname "$(realpath "$0")")"

source utils/_common.sh

confirm_requirements

# this will be cronned. if node is not running then quit
# so as not to inadvertently reactivate stopped docker
# services when the network resets
if ! ./utils/is_node_running.sh; then
    echo "$LOGPFX Node was not running, quitting"
    exit 2
fi

# Create tmp dir if not exists
mkdir -p tmp

TMPFILE=$(mktemp -p tmp -t genesis-XXXXX.json)
trap 'rm "$TMPFILE"' EXIT

# get latest genesis, commpare
./utils/get_genesis.sh > "$TMPFILE"

remote_md5=$(md5 "$TMPFILE")
local_md5=$(md5 "config/genesis.json")

if [ "$remote_md5" = "$local_md5" ]; then
    echo "$LOGPFX Local genesis is up to date $local_md5 = $remote_md5"
    echo "$LOGPFX Nothing to do"
else
    echo "$LOGPFX Local genesis was $local_md5, remote was $remote_md5"
    echo "$LOGPFX New genesis, resetting node"

    echo "$LOGPFX Resetting"
    ./utils/reset.sh -y

    ./utils/wait_node_start.sh

    echo "$LOGPFX Waiting for sync"
    ./utils/wait_sync.sh

    set -o xtrace
    pwd
    if [ -e "on-network-reset.sh" ]; then
        echo "$LOGPFX Running user bootstrap script on-network-reset.sh"
        exec ./on-network-reset.sh
    fi
fi
