#!/bin/bash

# Test peer's High Availablity

. utils.sh

# docker stop peer0.org1.example.com

cmd=./test_query_or_invoke.sh

test_query_op() {
    
    process_test_org

    $cmd $MODE 1 $ORG1 $@

    stop_docker peer0.org${ORG_NUM}.example.com
    
    $cmd $MODE 2 $ORG1 $@
    # $cmd $MODE 2 $ORG2 $@

    start_docker peer0.org${ORG_NUM}.example.com
}

test_invoke_op() {

    process_test_org

    stop_docker peer0.org${ORG_NUM}.example.com
    
    $cmd $MODE $ORG1 $@
    # $cmd $MODE $ORG2 $@

    start_docker peer0.org${ORG_NUM}.example.com
}

# get the orgs need to test
process_test_org() {
    if [ $ORG_NUM -eq 1 ]; then
        ORG1=2
        ORG2=3
    elif [ $ORG_NUM -eq 2 ]; then
        ORG1=1
        ORG2=3
    elif [ $ORG_NUM -eq 3 ]; then
        ORG1=1
        ORG2=2
    else 
        errorln "ORG Unknown"
    fi
}

printHelp() {
    println "HELP"
    println "   Please input params like this :"
    println "       ./test_peer_high_available.sh query 1 mychannel basic ReadAsset asset6"
    println "   or ./test_peer_high_available.sh invoke 1 mychannel basic TransferAsset asset6 PPP"
}

if [[ $# -lt 5 ]] ; then
    errorln "Params insufficient!"
    printHelp
    exit 0
else
    MODE=$1
    shift
fi

ORG_NUM=$1
shift

if [ "$MODE" == "query" ]; then
    test_query_op $@
elif [ "$MODE" == "invoke" ]; then
    test_invoke_op $@
else
    errorln "Mode illegal!"
    printHelp
    exit 0
fi