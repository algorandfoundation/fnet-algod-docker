# Fnet dockerized algod

Run `./run.sh` to fetch the latest genesis.json and start a docker instance

Run `./stop.sh` to stop the node

Run `./shell.sh` to start a shell in the docker container

Run goal commands with `./goal.sh` e.g. `./goal.sh node status`

`./check-update.sh` can be cronned to check for upstream network resets. If it finds a different genesis file, it will reset the node (wiping all local data) and restart it with the new genesis file. Finally it will run the on-automatic-reset.sh script, where you can place any bootstrap commands you want to execute, e.g. importing a mnemonic, waiting for funds and registering online.

`./reset.sh` will wipe local data and genesis file and restart the node

Participation keys in `partkeys/` will be copied into the data directory and automatically installed. TODO document suffix requirement
