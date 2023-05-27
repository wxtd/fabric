#! /bin/bash

# print functions in the chaincode

. utils.sh

# CHAINCODE_FILE=/home/ubuntu/ms/fabric-samples/asset-transfer-basic/chaincode-go/chaincode/smartcontract.go
CHAINCODE_FILE=$(dirname $(dirname "$PWD"))/asset-transfer-basic/chaincode-go/chaincode/smartcontract.go

function print_chaincode_function() {
    cat $CHAINCODE_FILE | sed -n '/^func /p' > $CHAINCODE_RESULT_ADDRESS/result.txt

    cat $CHAINCODE_RESULT_ADDRESS/result.txt
}

if [ ! -d "$CHAINCODE_RESULT_ADDRESS" ]; then
    mkdir -p $CHAINCODE_RESULT_ADDRESS
fi

print_chaincode_function