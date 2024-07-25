#!/usr/bin/env bash

function get_genesis() {
    bootstrap=_algobootstrap._tcp.fnet.algorand.green
    port=8184
    pfx="get_genesis:"

    resps=$(dig +short srv $bootstrap | cut -d\  -f4 | sed 's/\.$//' | shuf)

    echo "$pfx Resolved $(echo -e "$resps" | wc -l) relays" >&2

    for relayHostname in $resps; do
        if genesis=$(curl -s "http://$relayHostname:$port/genesis"); then
            echo "$pfx Got genesis, $(echo -e "$genesis" | wc -l) lines" >&2
            echo -e "$genesis"
            return 0
        fi
    done

    echo "$pfx Failed to get genesis"

    return 1
}

function create_tokens() {
  TOKEN_LENGTH=64 # minimum length: 64
  pfx="create_tokens:"

  for file in algod.token algod.admin.token; do
    filepath="persistent/$file"
    if [ -e "$filepath" ]; then
      echo "$pfx file $filepath already exists"
      return 13
    fi
    token=$(tr -dc A-Z0-9 </dev/urandom | head -c $TOKEN_LENGTH)
    echo -n "$token" > $filepath
    echo "$pfx Created $file $token"
  done

  return 0
}

export -f get_genesis
export -f create_tokens
