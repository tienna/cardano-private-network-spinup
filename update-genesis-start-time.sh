#!/usr/bin/env bash

set -euo pipefail

# Remove previously generated keys and files and db files

rm -rf $CNODE_HOME/db/*
rm -rf $CNODE_HOME/sockets/*
rm -rf $CNODE_HOME/files/*


# Create the genesis files and configs for the network, and the various keys that the nodes use.

[ -z ${NETWORK_MAGIC+x} ]&& ( echo "Environment variable NETWORK_MAGIC must be defined"; exit 1)

DELAY="${DELAY:-30}"

if [[ "$OSTYPE" == "darwin"* ]]; then
  SYSTEM_START=`date -u -v +${DELAY}M +'%Y-%m-%dT%H:%M:%SZ'`
  UNIX_EPOCH_TIME=`date -u -j -f "%FT%TZ" "$SYSTEM_START"  +\%s`
else
  SYSTEM_START=`date -u -d "today + $DELAY minutes" +'%Y-%m-%dT%H:%M:%SZ'`
  UNIX_EPOCH_TIME=`date +\%s -d "$SYSTEM_START"`
fi  

echo "Updating genesis using following environments variables:

 NETWORK_MAGIC: $NETWORK_MAGIC
 DELAY: $DELAY (delay in minutes before genesis systemStart)
 systemStart: $SYSTEM_START
"

EPOCH_LENGTH=`perl -E "say ((10 * $K) / $F)"`
EPOCH_LENGTH_MINUTES=`perl -E "say (($EPOCH_LENGTH / 60) * $SLOT_LENGTH )"`
EPOCH_LENGTH_MINUTES_INT=${EPOCH_LENGTH_MINUTES%.*}
RETURN_ADDRESS=$(cat keys/utxo-keys/utxo1_stk.addr)
echo "Epoch Length in minutes: $EPOCH_LENGTH_MINUTES"


# Create keys file

mkdir -p $CNODE_HOME/generated-keys/
mkdir -p $CNODE_HOME/initial-keys/
mkdir -p $CNODE_HOME/priv/pool/$POOL_NAME

# copy the config files

sed -i "s/\"startTime\": [0-9]*/\"startTime\": $UNIX_EPOCH_TIME/" "templates/genesis-byron.json" && \
sed -i "s/\"systemStart\": \".*\"/\"systemStart\": \"$SYSTEM_START\"/" "templates/genesis-shelley.json"

sed -i "s/\"protocolMagic\": [0-9]*/\"protocolMagic\": $NETWORK_MAGIC/" "templates/genesis-byron.json" 
sed -i "s/\"networkMagic\": [0-9]*/\"networkMagic\": $NETWORK_MAGIC/" "templates/genesis-shelley.json" 


cp templates/genesis-byron.json $CNODE_HOME/files/byron-genesis.json
cp templates/genesis-shelley.json $CNODE_HOME/files/shelley-genesis.json
cp templates/genesis-alonzo.json $CNODE_HOME/files/alonzo-genesis.json

cp templates/conway-genesis.json $CNODE_HOME/files/conway-genesis.json

cp templates/cardano-node.json $CNODE_HOME/files/config.json

cp templates/dbsync.json $CNODE_HOME/files/dbsync.json

cp templates/topology.json $CNODE_HOME/files/topology.json

#copy the keys

cp keys/node-keys/kes.skey $CNODE_HOME/priv/pool/$POOL_NAME/hot.skey
cp keys/node-keys/vrf.skey $CNODE_HOME/priv/pool/$POOL_NAME/vrf.skey
cp keys/node-keys/opcert.cert $CNODE_HOME/priv/pool/$POOL_NAME/op.cert

sudo chmod o-rwx $CNODE_HOME/priv/pool/$POOL_NAME/vrf.skey
sudo chmod g-rwx $CNODE_HOME/priv/pool/$POOL_NAME/vrf.skey

cp -r keys/utxo-keys/* $CNODE_HOME/initial-keys