# Fnet dockerized algod

## Overview

A set of scripts to configure and run a dockerized algod for [FNet](https://fnet.algorand.green/).

## Getting Started

Use the `run` script to configure and launch an FNet node

```
./run.sh
```

## Automatic Updates 

To update your node automatically, set up a cron job to execute `auto-update.sh`

The Fnet network may be reset. The scripts support automatically resetting the node to follow along with the new network.

The `on-network-reset.sh` script can also be utilized to bootstrap some user actions when a new instance of the network is created, such as keyreg online, create applications, fund other addresses, etc.

## KMD & Participation keys

A default passwordless KMD will be available in the container. Accounts you import **will** be persisted when you reset the network data dir (through `utils/reset.sh`)

Participation keys in `partkeys/` will be copied into the data directory and automatically installed **when the node first boots (without network data state)**. If you generate participation keys after booting your node, you can reset it with `./utils/reset.sh -y` and it will import the participation keys the next time you run `./run.sh`. _Note: the filename is required to follow this format: `[name].[first round].[last round].partkey` e.g. `2AQQU742K66T26EUYXH7CB3D4TL5KG7GN3S52CJZAYHDVQ76HFPSWCJUJ4.0.1000000.partkey`_

Participation keyfiles (.partkey) can be generated standalone using `utils/algokey`, e.g. `algokey part generate --parent 2AQQU742K66T26EUYXH7CB3D4TL5KG7GN3S52CJZAYHDVQ76HFPSWCJUJ4 --first 0 --last 1000000 --dilution 1000 --keyfile 2AQQU742K66T26EUYXH7CB3D4TL5KG7GN3S52CJZAYHDVQ76HFPSWCJUJ4.0.1000000.partkey`

## Table of Contents

These scripts are to be run on your **host** machine.

`./run.sh` **Entry point.** Configures a local docker algod instance and starts it

`./stop.sh` stops the docker instance

`./goal.sh` wraps goal, e.g. `./goal.sh node status`. It can also be piped to, e.g. `echo "apple apple ..." | ./goal.sh account import`

`./auto-update.sh` should be cronned to check for upstream network resets. When it finds a different genesis file, it will reset the node (wiping all local data) and restart it with the new genesis file. 👉 Finally it will run the `on-network-reset.sh` script, **where you can place any bootstrap commands you want to execute when the network resets**, e.g. waiting for funds and registering online. If you import accounts to goal/kmd, these will be persisted through resets.

## Utilities

These scripts are to be run on your **host** machine.

`./utils/shell.sh` starts a shell in the docker container

`./utils/reset.sh` clears local algod data and genesis file and restarts the node. Does not reset KMD data. This is required if genesis has changed since you last ran your node.

`./utils/catchup.sh` Starts fast catchup, waits for sync.

`./utils/create_tokens.sh` Creates algod.token and algod.admin.token

`./utils/get_account_eligibility.sh $account` Gets the specified $account's incentives eligibility.

`./utils/get_balance.sh $account` Gets microALGO balance of account `$account` through local node

`./utils/get_genesis.sh` Fetches latest genesis file from a relay

`./utils/is_node_running.sh` Exits successfully if node is running and ready

`./utils/is_node_syncing.sh` Exits successfully if node is syncing

`./utils/wait_for_balance.sh $account $amount` Waits until account `$account` has a balance of at least `$amount`

`./utils/wait_node_start.sh` Waits briefly for the node to start

`./utils/wait_sync.sh $timeout` Waits for node to sync, optionally with timeout of `$timeout` seconds

`./utils/wipe.sh` Resets the repository to initial state (note: also wipes KMD)

