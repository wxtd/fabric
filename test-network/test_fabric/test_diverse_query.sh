#! /bin/bash

. utils.sh
local cmd=./test_peer_high_available.sh
if [[ $# -lt 3 ]]; then
    errorln "Params insufficient!"
else
    $cmd 1 1 $@
    $cmd query 2 1 $@
fi