# Test_fabric

> Fabric-samples 搭建 test-network 并使用test_fabric下的脚本文件进行技术风险检测



## 初始化fabric网络（v2.+）

```shell
cd test-network

./network.sh up createChannel -c mychannel -s couchdb
 
./network.sh deployCC -ccn basic -ccp ../asset-transfer-basic/chaincode-go/ -ccl go

# 查看网络是否生成完毕 3orderer 2peer
docker ps -a
```

查询、更新

```shell
# org1

export PATH=${PWD}/../bin:$PATH
export FABRIC_CFG_PATH=$PWD/../config/
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org1MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
export CORE_PEER_ADDRESS=localhost:7051

peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer0.example.com --tls --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer0.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" -C mychannel -n basic --peerAddresses localhost:7051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt" --peerAddresses localhost:9051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt" -c '{"function":"InitLedger","Args":[]}'

# 查询
peer chaincode query -C mychannel -n basic -c '{"Args":["GetAllAssets"]}'

peer chaincode query -C mychannel -n basic -c '{"function":"ReadAsset","Args":["asset6"]}'

# 更新
peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer0.example.com --tls --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer0.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" -C mychannel -n basic --peerAddresses localhost:7051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt" --peerAddresses localhost:9051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt" -c '{"function":"TransferAsset","Args":["asset6","AAA"]}'

```



## 测试

测试中转结果存放在result文件夹中，测试最终结果打印在命令行

```shell
cd test_fabric

# 基础query & invoke
# 关于query
./test_query_or_invoke.sh query 1 1 mychannel basic ReadAsset asset6
./test_query_or_invoke.sh query 2 1 mychannel basic ReadAsset asset6
# or ./example_query.sh 1 && ./example_query.sh 2

# 关于invoke
./test_query_or_invoke.sh invoke 1 mychannel basic TransferAsset asset6 Amy
./test_query_or_invoke.sh invoke 1 mychannel basic DeleteAsset asset7
# or ./example_invoke.sh

# 测试是否使用微服务架构
./test_docker_architecture.sh

# 测试是否使用CA
./test_using_CA.sh

# 测试所有加密算法 若bug可替换其中的路径为密钥存放的绝对路径
./detect_encryption_method.sh

# 测试可维护性 使用混沌工程工具chaosblade制造故障
./test_blade.sh

# 打印链码所有函数（弃用）
./print_chaincode_function.sh

# 打印区块数据 是否加密
./test_data_crypt.sh

# 测试交易幂等性、持久性
./test_data_duration.sh

# 测试peer高可用性
./test_peer_high_available.sh invoke 1 mychannel basic TransferAsset asset6 PPP
# or in query mod
# ./test_peer_high_available.sh query 1 mychannel basic ReadAsset asset6

# 测试orderer高可用性
./test_orderer_high_available.sh orderer2.example.com query mychannel basic ReadAsset asset6

# 验证共识节点(Raft)
./test_orderer_raft.sh

# 测试链码风险（目前支持16种） 需要替换下面参数中的file/directory 换成待检测的链码文件夹或文件位置
cd tools/chaincode_analyzer/ccanalyzer
go build ccanalyzer.go
./ccanalyzer [file | directory]
```

