#!/bin/bash

# query if using CA

. utils.sh

function test_if_use_CA() {
    local cmd=`docker ps | awk '{print $2}' | grep fabric-ca`
    if [[ $cmd ]]; then
        infoln "Using CA!"
    else
        warnln "Not Using CA!"
    fi
}

test_if_use_CA