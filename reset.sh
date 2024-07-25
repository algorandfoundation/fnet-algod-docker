#!/usr/bin/env bash

cd "$(dirname "$(realpath "$0")")"

if [ "$1" != "-y" ]; then
  echo "This will destroy all data in the node and re-create it."
  echo "If you are running a participation node, please keyreg offline first and wait for 320 rounds before resetting"
  echo "Run this again with the -y argument to confirm:"
  echo -e "\n\t$0 -y\n"
  exit 1
fi

source _common.sh

./stop.sh

rm -rf "$LOCAL_DATA_DIR"

mkdir "$LOCAL_DATA_DIR"

./run.sh
