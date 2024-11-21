#!/bin/bash

set -e

cd "$(dirname "$(realpath "$0")")"

LATEST_LIST_PATH=catchpoints/lists/latest
LAST_KNOWN_PATH=catchpoints/last-known
LAST_GOOD_PATH=catchpoints/last-good

mkdir -p catchpoints/lists
if [ ! -f "$LAST_KNOWN_PATH" ]; then
    echo -n 0 > $LAST_KNOWN_PATH
fi

LR=$(curl -s https://fnet-api.d13.co/v2/status | jq -r '.["last-round"]')
last_known=$(cat $LAST_KNOWN_PATH | grep -oE '^[0-9]+')
next_expected=$(( last_known + 10000 ))

if [ $LR -lt $next_expected ]; then
    echo "Not time to check yet"
    exit 0
fi

echo Checking, last known: $last_known next expected: $next_expected current round: $LR

echo Getting catchpoints
./utils/get-all-catchpoints.sh > $LATEST_LIST_PATH

echo OK

latest=$(tail -n 1 $LATEST_LIST_PATH)
last_known=$(cat $LAST_KNOWN_PATH)

if [ "$latest" = "$last_known" ]; then
    echo "No new catchpoints"
    exit 0
fi

echo "Catchpoint update available"
echo "New: $latest"
echo "Previous last known: $last_known"

./stop.sh

timeout 1m ./utils/reset.sh -y || true

echo "OK"

./goal.sh node catchup $latest

sleep 2

echo "Using $latest"

while true; do
    echo Catching up..
    while ./goal.sh node status | grep verified > /dev/null; do
        echo -n "."
        sleep 5;
    done
    echo -e "\nCatchup finished"
    echo "Checking for last round after checkpoint"
    catchpoint_round=$(echo "$latest" | grep -oE "^[0-9]+")
    current_round=$(./goal.sh node lastround | grep -oE '[0-9]+')
    if [ $current_round -lt $catchpoint_round ]; then
        echo "Catchup failed. Aborting"
        ./stop.sh
        exit 1
    fi
    echo "Waiting for progress"
    if ./goal.sh node wait -w 45; then
        echo "Progress made! Catchpoint is good"
        tail -n 1 $LATEST_LIST_PATH > $LAST_KNOWN_PATH
        tail -n 1 $LATEST_LIST_PATH > $LAST_GOOD_PATH
        tail -n 1 $LATEST_LIST_PATH > site/latest
        cd site
        git add latest
        git commit -m "Last good catchpoint: $latest"
        git push
        cd ..
        ./stop.sh
        echo "Done"
        exit 0
    else
        echo "No progress made, catchpoint is bad"
        tail -n 1 $LATEST_LIST_PATH > $LAST_KNOWN_PATH
        ./stop.sh
        echo "Done"
        exit 0
    fi
done

./stop.sh
