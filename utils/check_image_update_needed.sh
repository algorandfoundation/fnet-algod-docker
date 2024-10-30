#!/usr/bin/env bash

# exits with 0 if we need to docker pull

LOGPFX=$(basename "$0"):
cd "$(dirname "$(realpath "$0")")/.."

set -e

loc=$(./utils/get_local_image_digest.sh)
remote=$(./utils/get_remote_image_digest.sh)

echo "$LOGPFX Checking for docker image updates"

if [ "$local" != "$remote" ]; then
    echo "$LOGPFX Update available"
    exit 0
fi

echo "$LOGPFX No updates available"
exit 1
