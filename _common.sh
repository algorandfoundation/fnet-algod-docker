#!/usr/bin/env bash

function get_genesis() {
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

function create_tokens() {
  local TOKEN_LENGTH=64 # minimum length: 64
  local LOGPFX="create_tokens:"

  for file in algod.token algod.admin.token; do
    local filepath="persistent/$file"
    if [ -e "$filepath" ]; then
      echo "$LOGPFX file $filepath already exists"
      return 13
    fi
    local token=$(tr -dc A-Z0-9 </dev/urandom | head -c $TOKEN_LENGTH)
    echo -n "$token" > $filepath
    echo "$LOGPFX Created $file $token"
  done

  return 0
}

export -f get_genesis
export -f create_tokens
