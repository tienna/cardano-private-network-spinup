#!/usr/bin/env bash
export K=6
export F=0.5
export SLOT_LENGTH=1
EPOCH_LENGTH=`perl -E "say ((10 * $K) / $F)"`
EPOCH_LENGTH_MINUTES=`perl -E "say (($EPOCH_LENGTH / 60) * $SLOT_LENGTH )"`
EPOCH_LENGTH_MINUTES_INT=${EPOCH_LENGTH_MINUTES%.*}
RETURN_ADDRESS=$(cat keys/utxo-keys/utxo1_stk.addr)
echo "Epoch Length in minutes: $EPOCH_LENGTH_MINUTES"