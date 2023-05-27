#! /bin/bash

# Detect encryption method

. utils.sh

KEY_ADDRESS=$(dirname "$PWD")/organizations
# KEY_ADDRESS=$(dirname "$PWD")/organizations

# function test_crypt_key() {
#     # PEER or ORDERER
#     local TYPE=$1
#     local ORG_ADDRESS=$2
#     array=(ca msp peers tlsca users)
#     if [[ ${TYPE} == "orderer" ]]; then
#         array[2]=orderers
#     fi

#     for item in ${array[*]}
#     do
#         if [[ ${item} == "msp" ]]; then
#             test_and_process ${TYPE} ${ORG_ADDRESS} ${item}/cacerts
#             test_and_process ${TYPE} ${ORG_ADDRESS} ${item}/tlscacerts
#         elif [[ ${item} == "ca" || ${item} == "tlsca" ]]; then
#             test_and_process ${TYPE} ${ORG_ADDRESS} ${item}
#         elif [[ ${item} == "users" ]]; then
#             test_and_process ${TYPE} ${ORG_ADDRESS} ${item}/Admin@${ORG_ADDRESS}/msp/cacerts
#             test_and_process ${TYPE} ${ORG_ADDRESS} ${item}/Admin@${ORG_ADDRESS}/msp/signcerts
#             test_and_process ${TYPE} ${ORG_ADDRESS} ${item}/Admin@${ORG_ADDRESS}/msp/tlscacerts
#             # test_and_process ${TYPE} ${ORG_ADDRESS} ${item}/Admin@${ORG_ADDRESS}/tls
#         else
#             local temp=$TYPE
#             if [[ $temp == "peer" ]]; then
#                 temp=peer0
#             else 
#                 temp=orderer0
#             fi
#             test_and_process ${TYPE} ${ORG_ADDRESS} ${item}/$temp.${ORG_ADDRESS}/msp/cacerts
#             test_and_process ${TYPE} ${ORG_ADDRESS} ${item}/$temp.${ORG_ADDRESS}/msp/signcerts
#             test_and_process ${TYPE} ${ORG_ADDRESS} ${item}/$temp.${ORG_ADDRESS}/msp/tlscacerts
#             # test_and_process ${TYPE} ${ORG_ADDRESS} ${item}/peer0.${ORG_ADDRESS}/tls
#         fi
#     done
# }

# function test_and_process() {
#     local TYPE=$1
#     local ORG_ADDRESS=$2
#     local CUR_ADDRESS=$3
#     # if ()
#     if [[ ${TYPE} == "peer" ]]; then
#         files=$(ls ${KEY_ADDRESS}/${PEER_ADDRESS}/${ORG_ADDRESS}/${CUR_ADDRESS}/*.pem 2> /dev/null | wc -l)
#         if [ "$files" != "0" ]; then
#             result=`openssl x509 -text -in ${KEY_ADDRESS}/${PEER_ADDRESS}/${ORG_ADDRESS}/${CUR_ADDRESS}/*.pem | grep Signature\ Algorithm: | awk '{print $3}' | uniq`
#         fi
#     else 
#         files=$(ls ${KEY_ADDRESS}/${ORDERER_ADDRESS}/${ORG_ADDRESS}/${CUR_ADDRESS}/*.pem 2> /dev/null | wc -l)
#         if [ "$files" != "0" ]; then
#             result=`openssl x509 -text -in ${KEY_ADDRESS}/${ORDERER_ADDRESS}/${ORG_ADDRESS}/${CUR_ADDRESS}/*.pem | grep Signature\ Algorithm: | awk '{print $3}' | uniq`
#         fi
#     fi
#     echo $result
# }

# function test_peer_and_orderer_crypt() {
    
#     ORDERER_LIST=(example.com)

#     PEER_LIST=(org1.example.com org2.example.com)

#     for item in ${ORDERER_LIST[*]}
#     do
#         test_crypt_key orderer ${item}
#     done

#     for item in ${PEER_LIST[*]}
#     do
#         test_crypt_key peer ${item}
#     done
# }


function test_peer_and_orderer_crypt() {
    getdir $KEY_ADDRESS
}

function getdir(){
    for element in `ls $1`
    do  
        dir_or_file=$1"/"$element
        if [ -d $dir_or_file ]; then 
            getdir $dir_or_file
        else
            if [[ "$dir_or_file" =~ ".crt" || "$dir_or_file" =~ ".pem" ]]; then
                # println $dir_or_file
                result=`openssl x509 -text -in $dir_or_file | grep Signature\ Algorithm: | awk '{print $3}' | uniq`
                println $result
            fi
        fi  
    done
}

test_peer_and_orderer_crypt
# test_and_process orderer example.com ca