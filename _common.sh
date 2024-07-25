#!/usr/bin/env bash

# If changed, update docker-compose as well
export LOCAL_DATA_DIR=data-fnet-v1
export LOCAL_KMD_DIR=data-kmd-v0.5
export TEMPLATE_KMD_DIR=template-kmd-v0.5

function get_genesis {
  # get latest genesis file from a relay
  local bootstrap=_algobootstrap._tcp.fnet.algorand.green
  local port=8184
  local LOGPFX="get_genesis:"

  local resps=$(dig +short srv $bootstrap | cut -d\  -f4 | sed 's/\.$//' | shuf)

  echo "$LOGPFX Resolved $(echo -e "$resps" | wc -l) relays" >&2

  for relayHostname in $resps; do
    if genesis=$(curl -s "http://$relayHostname:$port/genesis"); then
      echo "$LOGPFX Got genesis, $(echo -e "$genesis" | wc -l) lines" >&2
      echo -e "$genesis"
      return 0
    fi
  done

  echo "$LOGPFX Failed to get genesis"

  return 1
}

function create_tokens {
  local TOKEN_LENGTH=64 # minimum length: 64
  local LOGPFX="create_tokens:"

  for file in algod.token algod.admin.token; do
    local filepath="persistent/$file"
    if [ -e "$filepath" ]; then
      echo "$LOGPFX file $filepath already exists"
      return 13
    fi
    local token=$(LC_ALL=C tr -dc A-Z0-9 < /dev/urandom | head -c $TOKEN_LENGTH)
    echo -n "$token" > $filepath
    echo "$LOGPFX Created $file $token"
  done

  return 0
}

function md5 {
    md5sum "$1" | cut -d\  -f1
}

function is_node_running {
  if [[ $(docker inspect node-fnet 2> /dev/null | jq -r '.[]|select(.Name == "/node-fnet")|.State.Running') = "true" ]]; then
    return 0
  else
    return 1
  fi
}

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

function get_balance {
  ./goal.sh account dump -a "$1" | jq -r '.algo // 0'
}

function wait_for_balance {
  addr=$1
  amt=$2
  LOGPFX="wait_for_balance:"
  echo -n "$LOGPFX Waiting for ${addr:0:6}.. to reach $amt microalgo"
  while [ $(get_balance "$addr") -lt "$amt" ]; do
    echo -n "."
    sleep 30;
  done
}

export -f get_genesis
export -f create_tokens
export -f md5
export -f confirm_requirements
export -f get_balance
export -f wait_for_balance
