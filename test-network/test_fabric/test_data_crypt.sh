#! /bin/bash

# test if data of block is encrypted

. utils.sh

BLOCK_ADDRESS=result/block

function test_data_crypt() {
    get_block $1
    mv mychannel_$1.block $BLOCK_ADDRESS/mychannel_$1.block
    configtxlator proto_decode --input $BLOCK_ADDRESS/mychannel_$1.block --type common.Block --output $BLOCK_ADDRESS/trace.json

    local value=`cat $BLOCK_ADDRESS/trace.json | sed -n "/\"value\":\s/ p" | awk '{print $2}'`
    echo $value
    # echo ${#value}
}

if [ ! -d "$BLOCK_ADDRESS" ]; then
    mkdir -p $BLOCK_ADDRESS
fi

test_data_crypt 7