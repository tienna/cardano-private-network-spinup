# Cardano private network

## Prerequisites

For folder structure, we will use the guild operator scripts.

```bash
mkdir "$HOME/tmp";cd "$HOME/tmp"
curl -sS -o guild-deploy.sh https://raw.githubusercontent.com/cardano-community/guild-operators/master/scripts/cnode-helper-scripts/guild-deploy.sh
chmod 755 guild-deploy.sh
```

For cardano-node, we will use the latest pre-built binaries available which can be downloaded automatically in the ~/.local/bin directory.

```bash
./guild-deploy.sh -s d
```

## Update node producer pool name 
Before you go ahead with starting your node, update value for POOL_NAME in $CNODE_HOME/scripts/env.

```bash
POOL_NAME="pool1"
```

## Source the changes
```bash
. "${HOME}/.bashrc"
```

For latest guild operator commands and to build the binaries locally using cabal, refer the guild operator documenation.
(https://cardano-community.github.io/guild-operators/basics/)

       
## Configuring the deployment

All parameters are configured via environment variables (env.sh)
The POOL_NAME mentioned in the guild operator env file should match with the POOL_NAME mentioned for the private network so that the keys can be copied and the node can start as block producer.


```bash
source {your_environment_file}
```

#### Update the genesis files with a new start time:

```bash
./update-genesis-start-time.sh
```

Every execution of update-genesis-start-time.sh will generate a unique genesis file, because the parameter "systemStart" is the result of `date +${DELAY}`. If you've configured your enviroment with DELAY=5, you will have 5min to deploy the testnet. If no block producer is present at that point in time, the network (for that genesis hash) will be dead on arrival. 

This will also copy the config files and the keys to run the cardano node.

## Deploying private instance

1. Deploy as a systemd service
Execute the below command to deploy your node as a systemd service (from the respective scripts folder):

```bash
cd $CNODE_HOME/scripts
./cnode.sh -d
```


2. Start the service
Run below commands to enable automatic start of service on startup and start it.

```bash
sudo systemctl start cnode.service
```

3. Check status and stop/start commands Replace status with stop/start/restart depending on what action to take.

```bash
sudo systemctl status cnode.service
```

#### Important

In case you see the node exit unsuccessfully upon checking status, please verify you've followed the transition process correctly as documented below, and that you do not have another instance of node already running. It would help to check your system logs (/var/log/syslog for debian-based and /var/log/messages for Red Hat/CentOS/Fedora systems, you can also check journalctl -f -u <service> to examine startup attempt for services) for any errors while starting node.


## Next steps:

You can use gLiveView to monitor your node that was started as a systemd service.

```bash
cd $CNODE_HOME/scripts
./gLiveView.sh
```

## Generate Addresses and fund:

```bash
cd scripts
./step1-generate-utxo-keys-and-address.sh
```

Send funds to the address from the bootstrap node:
```bash
cd scripts
./faucet.sh <AMOUNT_IN_LOVELACE> <ADDRESS>
```