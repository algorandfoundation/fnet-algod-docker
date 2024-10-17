#!/usr/bin/env bash

LOGPFX=$(basename "$0"):
cd "$(dirname "$(realpath "$0")")/.."

set -eo xtrace

source utils/_common.sh

MIGRATED_LOCKFILE="$LOCAL_KMD_DIR/migrated.v1"

if [ -f "$MIGRATED_LOCKFILE" ]; then
    exit 0
fi

KMD_TOKEN_SHA=$(sha256 "$LOCAL_KMD_DIR/kmd.token")

function dump_mnemonics {
    if [ "$MNEMS" != "" ]; then
        echo -e "Unexpected exit - please import mnemonics manually:\n$MNEMS"
    fi
}

trap 'dump_mnemonics' INT
trap 'dump_mnemonics' EXIT

function start_node {
    echo "$LOGPFX Starting node"
    docker compose up -d

    echo -n "$LOGPFX Waiting for node to start "
    ./utils/wait_node_start.sh
}

MNEMS=""
if [ "$KMD_TOKEN_SHA" == "dfaa30304a49159eece365b7d02b2de40d86ecd3c8727fede05429b801aaab8b" ]; then
    echo "$LOGPFX Replacing vulnerable KMD"

    # Start node to export mnemonics
    if ! utils/is_node_running.sh; then
        start_node
    fi

    ADDRS=$(./goal.sh account list | grep -v "Did not find any account" | awk '{ print $3 }')
    ADDR_COUNT=$(echo -e "$ADDRS" | wc -l)
    if [ "$ADDR_COUNT" -gt 0 ]; then
        echo "$LOGPFX $ADDR_COUNT accounts to export"
        i=1
        for addr in $ADDRS; do
            mnem=$(./goal.sh account export -a "$addr" | cut -d\" -f2)
            MNEMS="${MNEMS}$mnem"$'\n'
            echo "$LOGPFX Exported mnemonic $i / $ADDR_COUNT"
            i=$(( i +1 ))
        done
    else
        echo "$LOGPFX No KMD accounts to export"
    fi

    echo "$LOGPFX Renaming old default wallet to vulnerable-caution"
    ./goal.sh wallet rename default vulnerable-caution

    echo "$LOGPFX Creating new KMD wallet"
    ./goal.sh wallet new default -n

    echo "$LOGPFX Setting new wallet as default"
    ./goal.sh wallet -f default

    touch "$MIGRATED_LOCKFILE"

    if [ "$ADDR_COUNT" -gt 0 ]; then
        i=1
        while IFS= read -r mnem && [[ -n $mnem ]]; do
            echo "$LOGPFX Importing $i / $ADDR_COUNT"
            echo "$mnem" | ./goal.sh account import -w default | grep -v "Please type your recovery mnemonic below"
            i=$(( i + 1 ))
        done <<< "$MNEMS"
    fi

    echo "$LOGPFX Done"
fi

trap '' INT
trap '' EXIT
