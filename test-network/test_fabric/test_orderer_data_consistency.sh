#! /bin/bash

# test fabric orderer data consistency

. utils.sh

ORDERER_RESULT_ADDRESS=result/orderer

orderer_list=(orderer0.example.com orderer1.example.com orderer2.example.com)

function test_orderer_data_consistency() {
    get_log

    local j=0
    # echo -e "Writing block [7] (Raft index: 11)" | sed -n '/Writing\sblock\s\[[0-9]\+\]\s(Raft\sindex:\s[0-9]\+)/ p'
    for i in ${orderer_list[*]}
    do 
        cat $ORDERER_RESULT_ADDRESS/orderer_test_$i.txt | grep block \
            | sed -n '/Writing\sblock\s\[[0-9]\+\]\s(Raft\sindex:\s[0-9]\+)/ p' \
            | awk '{print $9,$10,$11,$12,$13,$14}' ORS="\n" > $ORDERER_RESULT_ADDRESS/valid_log${j}.txt
        
        sort -u $ORDERER_RESULT_ADDRESS/valid_log${j}.txt > $ORDERER_RESULT_ADDRESS/temp${j}.txt

            # | awk '{for(i=9; i<=14; i++) {print $i}}' ORS="\n"
        let j++
    done
    # cat $ORDERER_RESULT_ADDRESS/orderer_test_orderer1.example.com.txt | grep block \
    #     | sed -n '/Writing\sblock\s\[[0-9]\+\]\s(Raft\sindex:\s[0-9]\+)/ p' \
    #     | awk '{print $9,$10,$11,$12,$13,$14}' ORS="\n" > b_tmp.txt
    local cnt=${#orderer_list[@]}
    comm -12 $ORDERER_RESULT_ADDRESS/temp0.txt $ORDERER_RESULT_ADDRESS/temp1.txt > $ORDERER_RESULT_ADDRESS/common.txt

    # cat $ORDERER_RESULT_ADDRESS/temp0.txt
    # cat $ORDERER_RESULT_ADDRESS/common.txt
    local idx=2
    while [[ idx -lt $cnt ]]
    do
        # echo $idx
        comm -12 $ORDERER_RESULT_ADDRESS/common.txt $ORDERER_RESULT_ADDRESS/temp$idx.txt > $ORDERER_RESULT_ADDRESS/temp.txt
        cat $ORDERER_RESULT_ADDRESS/temp.txt > $ORDERER_RESULT_ADDRESS/common.txt
        # cp $ORDERER_RESULT_ADDRESS/temp.txt $ORDERER_RESULT_ADDRESS/common.txt
        # sleep 3
        # rm $ORDERER_RESULT_ADDRESS/common.txt
        # mv $ORDERER_RESULT_ADDRESS/temp.txt $ORDERER_RESULT_ADDRESS/common.txt
        # cat $ORDERER_RESULT_ADDRESS/temp.txt
        let idx++
    done
    # cat $ORDERER_RESULT_ADDRESS/temp.txt
    if [[ -s $ORDERER_RESULT_ADDRESS/common.txt ]]; then
        successln "Common part:"
        cat $ORDERER_RESULT_ADDRESS/common.txt
    else 
        errorln "No common parts!"
    fi
    rm $ORDERER_RESULT_ADDRESS/common.txt
    rm $ORDERER_RESULT_ADDRESS/temp*.txt
    rm $ORDERER_RESULT_ADDRESS/valid_log*.txt
}

function get_log() {
    for i in ${orderer_list[*]}
    do
        # docker logs -f $i --tail 10 > result/orderer_test_$i.txt 2>&1 &
        # sleep 1 && kill -SIGINT $?
        get_last_log_from_orderer $i
    done
    # kill processes about docker logs
    # echo ${#orderer_list[@]}
    sleep 3 && kill -9 `ps -ef | grep docker\ logs | awk '{print $2}' | head -${#orderer_list[@]}` > /dev/null
}

function get_last_log_from_orderer() {
    local orderer_name=$1

    docker logs -f $orderer_name --tail 100 > $ORDERER_RESULT_ADDRESS/orderer_test_$orderer_name.txt 2>&1 &
}

if [ ! -d "$ORDERER_RESULT_ADDRESS" ]; then
    mkdir -p $ORDERER_RESULT_ADDRESS
fi

test_orderer_data_consistency