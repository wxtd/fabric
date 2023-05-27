#! /bin/bash

# test fabric orderer high available

# ./test_orderer_high_available.sh orderer2.example.com query mychannel basic ReadAsset asset6

. utils.sh

example_query_cmd=./example_query.sh
query_cmd=./test_query_or_invoke.sh

function test_query_op_orderer() {

    $query_cmd query 1 1 $@

    stop_docker $orderer_name

    $query_cmd query 2 2 $@

    start_docker $orderer_name
}

function test_invoke_op_orderer() {

    stop_docker $orderer_name

    $query_cmd invoke 1 $@

    start_docker $orderer_name
}

## Parse mode
if [[ $# -lt 5 ]] ; then
    errorln "Params insufficient!"
    printHelp
    exit 0
else
    orderer_name=$1
    shift
    MODE=$1
    shift
fi

if [[ "$MODE" == "query" ]]; then
    test_query_op_orderer $@
else 
    test_invoke_op_orderer $@
fi