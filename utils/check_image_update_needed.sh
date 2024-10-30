#!/usr/bin/env bash

# exits with 0 if we need to docker pull

LOGPFX=$(basename "$0"):
cd "$(dirname "$(realpath "$0")")/.."

set -e

echo "$LOGPFX Checking for docker image updates"

loc=$(./utils/get_local_image_digest.sh)
remote=$(./utils/get_remote_image_digest.sh)

if [ "$loc" == "$remote" ]; then
    echo "$LOGPFX No update available"
    exit 1
fi

echo "$LOGPFX Update available"
exit 0
