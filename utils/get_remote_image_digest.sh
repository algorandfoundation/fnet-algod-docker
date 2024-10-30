#!/usr/bin/env bash

LOGPFX=$(basename "$0"):
cd "$(dirname "$(realpath "$0")")/.."

source utils/_common.sh

ref="$DOCKER_IMAGE_TAG"
repo="${ref%:*}"
tag="${ref##*:}"
acceptM="application/vnd.docker.distribution.manifest.v2+json"
acceptML="application/vnd.docker.distribution.manifest.list.v2+json"
token=$(curl -s "https://auth.docker.io/token?service=registry.docker.io&scope=repository:${repo}:pull" \
        | jq -r '.token')

response=$(curl -H "Accept: ${acceptM}" \
     -H "Accept: ${acceptML}" \
     -H "Authorization: Bearer $token" \
     -I -s "https://registry-1.docker.io/v2/${repo}/manifests/${tag}")

dcd=$(echo -e "$response" | grep docker-content-digest)

if [ -z "$dcd" ]; then
        echo -e "$LOGPFX Unexpected response from dockerhub; docker-content-digest header not found in:\n\n$response"
        exit 1
fi

echo "$dcd" | cut -d\  -f2 | tr -d '\r\n'
