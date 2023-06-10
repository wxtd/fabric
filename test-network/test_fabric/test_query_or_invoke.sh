#!/bin/bash

# Test Fabric Query & Invoke Command


. utils.sh

# Firstly query and then save this result as log1.txt
saveQueryResult() {
    println "Querying~"
    # println $#
    
    processParam $@

    # println $ARGS

    # echo "peer chaincode query -C ${CHANNEL_NAME} -n ${CHAINCODE_NAME} \
    # -c '{"function":"'${FUNCTION_NAME}'","Args":['$ARGS']}' >$QUERY_OR_INVOKE_RESULT_ADDRESS/query_result1.txt 2>&1"
    # set -x
    $peer chaincode query -C ${CHANNEL_NAME} -n ${CHAINCODE_NAME} -c '{"function":"'${FUNCTION_NAME}'","Args":['$ARGS']}' >$QUERY_OR_INVOKE_RESULT_ADDRESS/query_result1.txt 2>&1
    # set +x
}


# compare query result with the query result firstly
CompareQueryResult() {
    # println "CompareQueryResult"
    println "Querying~"
    processParam $@

    $peer chaincode query -C ${CHANNEL_NAME} -n ${CHAINCODE_NAME} -c '{"function":"'${FUNCTION_NAME}'","Args":['$ARGS']}' >$QUERY_OR_INVOKE_RESULT_ADDRESS/query_result2.txt 2>&1

    result1=$QUERY_OR_INVOKE_RESULT_ADDRESS/query_result1.txt
    result2=$QUERY_OR_INVOKE_RESULT_ADDRESS/query_result2.txt
    cmp --silent $result1 $result2 && result=1 || result=0
    # println $result
    if [ $result -eq 1 ]; then
        successln "Query result is the same!"
    else
        errorln "Query result is different"
    fi
}

# Invoke cmd result
# Chaincode invoke successful. result: status:200
ivokeChaincode() {
    println "Invoking~"
    processParam $@

    ADDRESS=$(dirname "$PWD")
    
    if [ $ORG_NUM -eq 1 ]; then
        org1=2
        org2=3
        port1=9051
        port2=11051
    elif [ $ORG_NUM -eq 2 ]; then
        org1=1
        org2=3
        port1=7051
        port2=11051
    elif [ $ORG_NUM -eq 3 ]; then
        org1=1
        org2=2
        port1=7051
        port2=9051
    fi

    # $peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer0.example.com --tls \
    # --cafile "${ADDRESS}/organizations/ordererOrganizations/example.com/orderers/orderer0.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" \
    # -C ${CHANNEL_NAME} -n ${CHAINCODE_NAME} \
    # --peerAddresses localhost:${port1} --tlsRootCertFiles "${ADDRESS}/organizations/peerOrganizations/org${org1}.example.com/peers/peer0.org${org1}.example.com/tls/ca.crt" \
    # --peerAddresses localhost:${port2} --tlsRootCertFiles "${ADDRESS}/organizations/peerOrganizations/org${org2}.example.com/peers/peer0.org${org2}.example.com/tls/ca.crt" \
    # -c '{"function":"'${FUNCTION_NAME}'","Args":['$ARGS']}' > $QUERY_OR_INVOKE_RESULT_ADDRESS/invoke_result.txt 2>&1

    $peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer0.example.com --tls \
    --cafile "${ADDRESS}/organizations/ordererOrganizations/example.com/orderers/orderer0.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" \
    -C ${CHANNEL_NAME} -n ${CHAINCODE_NAME} \
    --peerAddresses localhost:${port2} --tlsRootCertFiles "${ADDRESS}/organizations/peerOrganizations/org${org2}.example.com/peers/peer0.org${org2}.example.com/tls/ca.crt" \
    -c '{"function":"'${FUNCTION_NAME}'","Args":['$ARGS']}' > $QUERY_OR_INVOKE_RESULT_ADDRESS/invoke_result.txt 2>&1

    # $peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer0.example.com --tls \
    # --cafile "${ADDRESS}/organizations/ordererOrganizations/example.com/orderers/orderer0.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" \
    # -C ${CHANNEL_NAME} -n ${CHAINCODE_NAME} \
    # -c '{"function":"'${FUNCTION_NAME}'","Args":['$ARGS']}' > $QUERY_OR_INVOKE_RESULT_ADDRESS/invoke_result.txt 2>&1

    invoke_result=$QUERY_OR_INVOKE_RESULT_ADDRESS/invoke_result.txt
    success="Chaincode invoke successful. result: status:200"

    if [ `grep -c "$success" $invoke_result` -ne '0' ];then
        successln "Invoke Success!"
    else
        errorln "Invoke Failed"
    fi
}

# Process Parameters
processParam() {
    if [ $# -eq 0 ]; then
        ARGS="\"\""
    else
        ARGS="\"$1\""
        shift
    fi
    for i in "$@"
    do
        ARGS=$ARGS",""\"$i\""
    done
}

# Print Help
printHelp() {
    println "Help:"
    println "   ./test_query_or_invoke.sh [TEST_MOD] [OPTION:TURN] [ORG_NUM] [CHANNEL_NAME] [CHAINCODE_NAME] [FUNCTION_NAME] [ARGS]"
    println "   Params:"
    println "       TEST_MOD: query / invoke"
    println "       TURN: 1 / 2"
    println "       ORG_NUM: 1 / 2 / 3"
    println "   Please input params like this :"
    println "       ./test_query_or_invoke.sh query 1 1 mychannel basic ReadAsset asset6"
    println "    or ./test_query_or_invoke.sh invoke 1 mychannel basic TransferAsset asset6 Amy"
}

if [ ! -d "$QUERY_OR_INVOKE_RESULT_ADDRESS" ]; then
    mkdir -p $QUERY_OR_INVOKE_RESULT_ADDRESS
fi

# if [ ! -f "$QUERY_OR_INVOKE_RESULT_ADDRESS/success_invoke.txt" ]; then
#     println "file not exists!"
#     echo "Chaincode invoke successful. result: status:200" > result/success_invoke.txt
# fi

## Parse mode
if [[ $# -lt 5 ]] ; then
    errorln "Params insufficient!"
    printHelp
    exit 0
else
    MODE=$1
    shift
fi

if [ "$MODE" == "query" ]; then
    TURN=$1
    shift
    ORG_NUM=$1
    CHANNEL_NAME=$2
    CHAINCODE_NAME=$3
    FUNCTION_NAME=$4
    shift 4
    setGlobals $ORG_NUM
    if [ $TURN -eq 1 ]; then
        saveQueryResult $@
    else 
        CompareQueryResult $@
    fi
elif [ "$MODE" == "invoke" ]; then
    ORG_NUM=$1
    CHANNEL_NAME=$2
    CHAINCODE_NAME=$3
    FUNCTION_NAME=$4
    shift 4
    setGlobals $ORG_NUM
    ivokeChaincode $@
else
    errorln "Mode illegal!"
    printHelp
    exit 0
fi
