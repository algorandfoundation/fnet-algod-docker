#!/usr/bin/env bash

cd "$(dirname "$(realpath "$0")")/.."

if [ "$1" != "-y" ]; then
  echo "This will destroy all data in the node and re-create it."
  echo "If you are running a participation node, please keyreg offline first and wait for 320 rounds before resetting"
  echo "Note: your KMD (imported accounts) will NOT be reset"
  echo "Run this again with the -y argument to confirm:"
  echo -e "\n\t$0 -y\n"
  exit 1
fi

source utils/_common.sh

# stop node if needed
./stop.sh

# delete and recreate local data dir
rm -rf "$LOCAL_DATA_DIR"
mkdir "$LOCAL_DATA_DIR"

./utils/get_genesis.sh > config/genesis.json

# configure and run node
./run.sh
