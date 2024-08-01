#!/usr/bin/env bash

set -e
shopt -s nullglob
LOGPFX=$(basename "$0"):

cd "$(dirname "$(realpath "$0")")"

source utils/_common.sh

# Check all requirements are installed
confirm_requirements

# TODO fetch and compare, warn that a reset is needed if it has changed
if [ ! -f config/genesis.json ]; then
    # Fetch latest genesis from a relay
    get_genesis > config/genesis.json
# if we have a genesis AND the local data dir is initialized, check compatibility
elif [ -f "$LOCAL_DATA_DIR/ledger.block.sqlite"  ]; then
    TMPFILE=$(mktemp -p tmp -t genesis-XXXXX.json)
    trap 'rm "$TMPFILE"' EXIT

    # get latest genesis, commpare
    get_genesis > "$TMPFILE"

    remote_md5=$(md5 "$TMPFILE")
    local_md5=$(md5 "config/genesis.json")

    if [[ "$remote_md5" != "$local_md5" ]]; then
        echo "$LOGPFX Error: genesis has changed. You need to reset your data directory with ./utils/reset.sh"
        exit 1
    fi
fi

if [ ! -e "$LOCAL_KMD_DIR" ]; then
    echo "$LOGPFX initializing local KMD directory"
    cp -r "$TEMPLATE_KMD_DIR" "$LOCAL_KMD_DIR"
    chmod 700 "$LOCAL_KMD_DIR"
fi

# create tokens if needed. acceptable exit codes: 0, 13
set +e
create_tokens
ct_exit=$?
set -e

if [ $ct_exit -eq 13 ]; then
    echo "$LOGPFX Tokens exist, continuing"
elif [ $ct_exit -eq 0 ]; then
    echo "$LOGPFX Created algod and admin tokens"
else
    echo "$LOGPFX error"
    exit 1
fi

# Create data directories if needed
mkdir -p "$LOCAL_DATA_DIR" "$LOCAL_KMD_DIR" tmp

# Copy participation keys from partkeys/* into node
# Matches required suffix [name].[first round].[last round].partkey
COPIED_PART=0
for filepath in partkeys/*.*.*.partkey; do
    filename=$(basename "$filepath")
    destpath="$LOCAL_DATA_DIR/$filename"
    if [ -e "$destpath" ]; then
        echo "$LOGPFX Skipping $filepath because destination file exists"
        continue
    else
        cp "$filepath" "$destpath"
        echo "$LOGPFX Copied $filepath -> $destpath"
        COPIED_PART=1
    fi
done

echo "$LOGPFX Fetching latest docker image"
docker pull tasosbit/algod-fnet:latest

if is_node_running; then
    echo "$LOGPFX node is running, stopping it"
    ./stop.sh
fi

echo "$LOGPFX Starting node in background"
docker compose up -d

# container boot time
sleep 2

# emit note if we copied part keys
if [ $COPIED_PART -eq 1 ]; then
    echo -e "$LOGPFX Info: Copied participation keys. Check that they were automatically installed with:\n\n\t./goal.sh account partkeyinfo\n"
fi

# Wait to sync normally, then start fast catchup
echo "$LOGPFX Waiting 90 seconds for sync. Ctrl+C to skip"
trap 'kill -INT -$pid' INT
set +e
timeout 90 ./utils/wait-sync.sh &
pid=$!
wait $pid
set -e

if is_node_syncing; then
    echo "$LOGPFX Not synced yet, starting fast catchup"
    ./utils/catchup.sh
fi

echo "$LOGPFX OK"
