#!/usr/bin/env bash

function get_genesis {
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
    local token=$(tr -dc A-Z0-9 < /dev/urandom | head -c $TOKEN_LENGTH)
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

function is_jq_installed {
  if jq --version > /dev/null; then return 0; else return 1; fi
}

function ensure_jq_installed {
  if ! is_jq_installed; then
    echo "Error: jq must be installed"
    exit 1
  fi
}


function get_balance {
    ./goal.sh account dump -a $1 | jq -r '.algo // 0'
}

function wait_for_balance {
    addr=$1
    amt=$2
    LOGPFX="wait_for_balance:"
    echo -n "$LOGPFX Waiting for ${addr:0:6}.. to reach $amt microalgo"
    while [ $(get_balance $addr) -lt $amt ]; do
        echo -n "."
        sleep 30;
    done
}

export -f get_genesis
export -f create_tokens
export -f md5
export -f ensure_jq_installed
export -f get_balance
export -f wait_for_balance
