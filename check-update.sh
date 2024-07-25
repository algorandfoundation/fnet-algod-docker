#!/usr/bin/env bash

set -e

LOGPFX=$(basename "$0"):
cd "$(dirname "$(realpath "$0")")"

source _common.sh

confirm_requirements

# this will be cronned. if node is not running then quit
# so as not to inadvertently reactivate stopped docker
# services when the network resets
if ! is_node_running; then
    echo "$LOGPFX Node was not running, quitting"
    exit 2
fi

# Create tmp dir if not exists
mkdir -p tmp

TMPFILE=$(mktemp -p tmp -t genesis-XXXXX.json)
trap 'rm "$TMPFILE"' EXIT

# get latest genesis, commpare
get_genesis > "$TMPFILE"

remote_md5=$(md5 "$TMPFILE")
local_md5=$(md5 "persistent/genesis.json")

if [ "$remote_md5" = "$local_md5" ]; then
    echo "$LOGPFX Local genesis is up to date $local_md5 = $remote_md5"
    echo "$LOGPFX Nothing to do"
else
    echo "$LOGPFX Local genesis was $local_md5, remote was $remote_md5"
    echo "$LOGPFX New genesis, resetting node"

    echo "$LOGPFX Resetting"
    ./reset.sh -y

    sleep 3

    echo "$LOGPFX Waiting for sync"
    ./wait-sync.sh

    if [ -e "on-automatic-reset.sh" ]; then
        echo "$LOGPFX Running user bootstrap script on-automatic-reset.sh"
        exec on-automatic-reset.sh
    fi
fi
