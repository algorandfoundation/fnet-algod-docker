#!/usr/bin/env bash

set -e
shopt -s nullglob

cd "$(dirname "$(realpath "$0")")"

source _common.sh

get_genesis > persistent/genesis.json

# create tokens. acceptable exit codes: 0, 13
set +e
create_tokens
ct_exit=$?
set -e

if [ $ct_exit -eq 13 ]; then
    echo "$0: Tokens exist, continuing"
elif [ $ct_exit -eq 0 ]; then
    echo "$0: Created algod and admin tokens"
else
    echo "$0: error"
    exit 1
fi

mkdir -p data

COPIED_PART=0
# Copy participation keys
# Matches required suffix [name].[first round].[last round].partkey
for filepath in partkeys/*.*.*.partkey; do
    filename=$(basename "$filepath")
    destpath="data/$filename"
    if [ -e "$destpath" ]; then
        echo "$0: Skipping $filepath because destination $destpath already exists"
        continue
    else
        cp "$filepath" "$destpath"
        echo "$0: Copied $filepath -> $destpath"
        COPIED_PART=1
    fi
done

./stop.sh

echo "$0: Starting node in background"
docker compose up -d

echo "$0: OK"

if [ $COPIED_PART -eq 1 ]; then
    echo -e "$0: Info: Copied participation keys. Check that they were automatically installed with:\n\n\t./goal.sh account partkeyinfo\n"
fi
