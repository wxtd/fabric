#!/bin/bash

# query if using docker architecture

. utils.sh

function test_if_use_docker_architecture() {
    local cmd=`docker ps | awk '{print $2}' | grep fabric`
    if [[ $cmd ]]; then
        infoln "Using Docker Architecture!"
    else
        warnln "Not Using Docker Architecture!"
    fi
}

test_if_use_docker_architecture