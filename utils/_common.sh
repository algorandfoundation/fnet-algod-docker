#!/usr/bin/env bash

export LOCAL_DATA_DIR=data-fnet-v1

export LOCAL_KMD_DIR=data-kmd-v0.5

export TEMPLATE_KMD_DIR=template-kmd-v0.5

export GOAL_CMD="./goal.sh"

export DOCKER_CLI_HINTS=false

export DOCKER_IMAGE_TAG=tasosbit/algod-fnet:latest

# auto-update does not work on Mac without this
export PATH="$PATH:/usr/local/bin:/opt/homebrew/bin"

function confirm_requirements {
  # check that requirements are installed
  # override default list by calling with arguments
  reqs=${@:-docker curl dig md5sum jq tr cut sed shuf wc}
  echo -n "confirm_requirements: "
  for req in $reqs; do
    if ! which "$req" > /dev/null 2>&1; then
      echo ""
      echo -e "\nError: '$req' is required but not installed" >&2
      exit 1
    else
      echo -n "$req "
    fi
  done
  echo "OK"
}
export -f confirm_requirements

function md5 {
    md5sum "$1" | cut -d\  -f1
}
export -f md5

function sha256 {
    sha256sum "$1" | cut -d\  -f1
}
export -f sha256
