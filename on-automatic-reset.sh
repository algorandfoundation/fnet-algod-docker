#!/usr/bin/env bash

# CHANGE ME

# This script will run after an automated reset due to a network reset/genesis change
# If you want to automate any "network bootstrap" actions such as registering participation keys or funding accounts, you can do this here

# Example: import key, wait for funds, sends keyreg online

cd "$(dirname "$(realpath "$0")")"

source _common.sh

ensure_jq_installed

# waits for address to have at least 100 ALGO
wait_for_balance 7IBEAXHK62XEJATU6Q4QYQCDFY475CEKNXGLYQO6QSGCLVMMK4SLVTYLMY 100000000


