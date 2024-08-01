#!/bin/bash

# Deletes tokens and node data

cd "$(dirname "$(realpath "$0")")"
cd ..

source utils/_common.sh

cmd="rm -rf $LOCAL_KMD_DIR $LOCAL_DATA_DIR config/*token config/genesis.json partkeys/*"

if [ "$1" != "-y" ]; then
  echo "WARNING: This will wipe all local data, resetting the directory to blank slate"
  echo "To be deleted: local node data, kmd, algod tokens, participation keys"
  echo -e "It will execute: $cmd\n"
  echo "Run this again with the -y argument to confirm:"
  echo -e "\n\t$0 -y\n"
  exit 1
fi

exec $cmd
