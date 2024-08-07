#!/usr/bin/env bash

LOGPFX=$(basename "$0"):
cd "$(dirname "$(realpath "$0")")/.."

set -e

source utils/_common.sh

TOKEN_LENGTH=64 # minimum length: 64
LOGPFX="create_tokens:"

for file in algod.token algod.admin.token; do
  filepath="config/$file"
  if [ -e "$filepath" ]; then
    echo "$LOGPFX file $filepath already exists"
    exit 0
  fi
  token=$(LC_ALL=C tr -dc A-Z0-9 < /dev/urandom | head -c $TOKEN_LENGTH)
  echo -n "$token" > $filepath
  echo "$LOGPFX Created $file $token"
done

exit 0
