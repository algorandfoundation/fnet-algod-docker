# Fnet dockerized algod

Scripts:

`./run.sh` sets up genesis.json and start a docker instance

`./stop.sh` stops the node

`./goal.sh` wraps goal, e.g. `./goal.sh node status` - it can also be piped to, e.g. `echo "apple applie ..." | ./goal.sh account import`

`./reset.sh` wipes local network data and genesis file and restart the node. This is required if genesis has changed since you ran your node.

`./check-update.sh` can be cronned to check for upstream network resets. If it finds a different genesis file, it will reset the node (wiping all local data) and restart it with the new genesis file. Finally it will run the on-automatic-reset.sh script, where you can place any bootstrap commands you want to execute, e.g. waiting for funds and registering online. If you import accounts to goal/kmd, these will be persisted through resets.

`./shell.sh` starts a shell in the docker container

A default passwordless KMD will be available in the container. Accounts you import **will** be persisted when you reset the data dir.

Participation keys in `partkeys/` will be copied into the data directory and automatically installed. Note: the filename is required to follow this format: `[name].[first round].[last round].partkey` e.g. `2AQQU742K66T26EUYXH7CB3D4TL5KG7GN3S52CJZAYHDVQ76HFPSWCJUJ4.0.1000000.partkey`

Participation keyfiles (.partkey) can be generated standalone using utils/algokey, e.g. `algokey part generate --parent 2AQQU742K66T26EUYXH7CB3D4TL5KG7GN3S52CJZAYHDVQ76HFPSWCJUJ4 --first 0 --last 1000000 --dilution 1000 --keyfile 2AQQU742K66T26EUYXH7CB3D4TL5KG7GN3S52CJZAYHDVQ76HFPSWCJUJ4.0.1000000.partkey`
