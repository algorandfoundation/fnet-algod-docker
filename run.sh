#!/usr/bin/env bash

set -e
shopt -s nullglob
LOGPFX=$(basename "$0"):

cd "$(dirname "$(realpath "$0")")"

source utils/_common.sh

WAIT_SYNC_TIME_BEFORE_CATCHUP=9 # seconds

# Check all requirements are installed
confirm_requirements

# First run; fetch latest genesis from a relay
if [ ! -f config/genesis.json ]; then
    ./utils/get_genesis.sh > config/genesis.json
elif [ -f "$LOCAL_DATA_DIR/ledger.block.sqlite"  ]; then
    # if we have a genesis AND the local data dir is initialized, check compatibility
    # get latest genesis, commpare
    remote_md5=$(./utils/get_genesis.sh | md5sum | cut -d\  -f1)
    local_md5=$(md5 "config/genesis.json")

    if [[ "$remote_md5" != "$local_md5" ]]; then
        echo "$LOGPFX Error: genesis has changed. You need to reset your data directory with ./utils/reset.sh"
        exit 1
    fi
fi

# create tokens if needed. acceptable exit codes: 0, 13
./utils/create_tokens.sh

# Create data directories if needed
mkdir -p "$LOCAL_DATA_DIR" "$LOCAL_KMD_DIR" tmp partkeys

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
docker pull "$DOCKER_IMAGE_TAG"

NEW_KMD=0
# Initialize data and KMD directories
# Migrate may start the node - this must happen when we are ready for that
if [ ! -e "$LOCAL_KMD_DIR/kmd.token" ]; then
    echo "$LOGPFX initializing local KMD directory"
    mkdir -p "$LOCAL_KMD_DIR"
    chmod 700 "$LOCAL_KMD_DIR"
    NEW_KMD=1
else
    ./utils/migrate-vulnerable-kmd.sh
fi

if ./utils/is_node_running.sh; then
    echo "$LOGPFX node is running, stopping it"
    ./stop.sh
fi

echo "$LOGPFX Starting node in background"
docker compose up -d

# emit note if we copied part keys
if [ $COPIED_PART -eq 1 ]; then
    echo -e "$LOGPFX Info: Copied participation keys. Check that they were automatically installed with:\n\n\t$GOAL_CMD account partkeyinfo\n"
fi

echo -n "$LOGPFX Waiting for node to start"
./utils/wait_node_start.sh

if ! ./utils/is_node_running.sh; then
    echo -e "\n$LOGPFX ERROR algod failed to start"
    exit 1
else
    echo "OK"
fi

if [ $NEW_KMD -eq 1 ]; then
    echo -e "\n$LOGPFX Creating KMD wallet"
    $GOAL_CMD wallet new default -n
fi

sleep 5 # give some more time, had "synced" false positives

# Wait to sync normally, then start fast catchup
echo "$LOGPFX Waiting $WAIT_SYNC_TIME_BEFORE_CATCHUP seconds for sync. Ctrl+C to skip"
if ! ./utils/wait_sync.sh $WAIT_SYNC_TIME_BEFORE_CATCHUP; then
    echo "$LOGPFX Not synced after $WAIT_SYNC_TIME_BEFORE_CATCHUP seconds. Doing fast catchup"
    if ! ./utils/catchup.sh; then
        echo "$LOGPFX Fast catchup failed; waiting for sync indefinitely"
        ./utils/wait_sync.sh
    fi
fi

echo "$LOGPFX OK"
