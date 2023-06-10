#! /bin/bash

# test fabric orderer consensus algorithm

# Example: 

. utils.sh

example_query_cmd=./example_query.sh
example_invoke_cmd=./example_invoke.sh
test_orderer_data_consistency_cmd=./test_orderer_data_consistency.sh

function test_raft() {

    $example_query_cmd 1

    stop_docker orderer2.example.com
    # stop_docker orderer1.example.com

    $example_query_cmd 2
    $example_invoke_cmd

    start_docker orderer2.example.com

    println "sleep 10~"
    sleep 10
    $test_orderer_data_consistency_cmd
}

if [ ! -d "$ORDERER_RESULT_ADDRESS" ]; then
    mkdir -p $ORDERER_RESULT_ADDRESS
fi

test_raft