#!/usr/bin/env bash

cd "$(dirname "$(realpath "$0")")/.."

source utils/_common.sh

docker image inspect "$DOCKER_IMAGE_TAG" | jq -r '.[0].RepoDigests[0]' | cut -d@ -f2- | tr -d '\r\n'
