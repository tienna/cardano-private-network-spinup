#!/usr/bin/env bash

export GREEN='\033[0;32m'  
export BLUE='\033[0;36m' 
export GREY='\032[0;36m' 
export RED='\033[0;31m' 
export NC='\033[0m' # No Color

UTXO_KEYS_PATH=$CNODE_HOME/generated-keys/utxo-keys
POOL_KEYS_PATH=$CNODE_HOME/generated-keys/pool-keys
CONFIGS_PATH=$CNODE_HOME/files
TMP_PATH=~/tmp


mkdir -p $UTXO_KEYS_PATH
mkdir -p $POOL_KEYS_PATH
mkdir -p $TMP_PATH


export PATH="~/bin:$PATH"
export CARDANO_NODE_SOCKET_PATH=$CNODE_HOME/sockets/node.socket

if [ "$(ls -A $UTXO_KEYS_PATH)" ]; then	
    echo -e "\n${RED}abort ... $UTXO_KEYS_PATH is not an empty directory and your keys would get overwritten${NC}\n"
    exit 1
fi

cardano-cli address key-gen \
--verification-key-file $UTXO_KEYS_PATH/payment.vkey \
--signing-key-file $UTXO_KEYS_PATH/payment.skey

cardano-cli stake-address key-gen \
--verification-key-file $UTXO_KEYS_PATH/stake.vkey \
--signing-key-file $UTXO_KEYS_PATH/stake.skey

cardano-cli address build \
--payment-verification-key-file $UTXO_KEYS_PATH/payment.vkey \
--stake-verification-key-file $UTXO_KEYS_PATH/stake.vkey \
--out-file $UTXO_KEYS_PATH/payment.addr \
--testnet-magic $NETWORK_MAGIC

cardano-cli stake-address build \
--stake-verification-key-file $UTXO_KEYS_PATH/stake.vkey \
--out-file $UTXO_KEYS_PATH/stake.addr \
--testnet-magic $NETWORK_MAGIC

read -r -d '' output <<-EOF

\n${GREEN}keys and address created in:${NC}
${BLUE}$UTXO_KEYS_PATH${NC}

${GREEN}Your address:${NC}
${BLUE}$(cat $UTXO_KEYS_PATH/payment.addr)${NC}

${GREEN}Next, request funds to be sent to this address from the bootstrap node.${NC}

${GREEN}Then check your utxo balance:${NC}
${GREEN}export CARDANO_NODE_SOCKET_PATH=$CARDANO_NODE_SOCKET_PATH{NC}
${BLUE}cardano-cli query utxo --address $(cat $UTXO_KEYS_PATH/payment.addr) --testnet-magic $NETWORK_MAGIC${NC}\n
           
EOF
echo -e "$output"