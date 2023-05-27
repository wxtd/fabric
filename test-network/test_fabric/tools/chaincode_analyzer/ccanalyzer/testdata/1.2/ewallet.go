package main

import (
	"bytes"
	"fmt"
	"strconv"
	"time"

	"github.com/hyperledger/fabric/core/chaincode/shim"
	pb "github.com/hyperledger/fabric/protos/peer"
)

type EWallet struct {
}

//type account struct {
//	User    string `json:"user"`
//	Balance int `json:"balance"`
//}

func (e *EWallet) Init(stub shim.ChaincodeStubInterface) pb.Response {
	return shim.Success(nil)
}

func (e *EWallet) Invoke(stub shim.ChaincodeStubInterface) pb.Response {
	function, args := stub.GetFunctionAndParameters()
	fmt.Println("invoke is running " + function)

	// Handle different functions
	if function == "createAccount" { //create a new account
		return e.createAccount(stub, args)
	} else if function == "transferAccount" { //transfer one to another
		return e.transferAccount(stub, args)
	} else if function == "queryAccount" { //query an account
		return e.queryAccount(stub, args)
	} else if function == "deleteAccount" { //delete an account
		return e.deleteAccount(stub, args)
	} else if function == "saveMoney" { //save money
		return e.saveMoney(stub, args)
	} else if function == "drawMoney" { //draw money
		return e.drawMoney(stub, args)
	} else if function == "queryAllAccounts" { //query all accounts
		return e.queryAllAccounts(stub, args)
	} else if function == "getHistoryForAccount" { //query history for account
		return e.getHistoryForAccount(stub, args)
	}

	fmt.Println("invoke did not find func: " + function) //error
	return shim.Error("Received unknown function invocation")
}

func (e *EWallet) createAccount(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	var err error

	if len(args) != 1 {
		return shim.Error("Incorrect number of arguments. Expecting 1")
	}

	user := args[0]
	balance := strconv.Itoa(0)

	// ==== Check if user already exists ====
	userAsBytes, err := stub.GetState(user)
	if err != nil {
		return shim.Error("Failed to get user: " + err.Error())
	} else if userAsBytes != nil {
		fmt.Println("This user already exists: " + user)
		return shim.Error("This user already exists: " + user)
	}

	err = stub.PutState(user, []byte(balance))
	if err != nil {
		return shim.Error(err.Error())
	}

	return shim.Success(nil)
}

func (e *EWallet) transferAccount(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	var Auser, Buser string
	var Abalance, Bbalance int
	var X int
	var err error

	if len(args) != 3 {
		return shim.Error("Incorrect number of arguments. Expecting 3")
	}

	Auser = args[0]
	Buser = args[1]

	Abalancebytes, err := stub.GetState(Auser)
	if err != nil {
		return shim.Error("Failed to get state")
	}
	if Abalancebytes == nil {
		return shim.Error("Account not found")
	}
	Abalance, _ = strconv.Atoi(string(Abalancebytes))

	Bbalancebytes, err := stub.GetState(Buser)
	if err != nil {
		return shim.Error("Failed to get state")
	}
	if Bbalancebytes == nil {
		return shim.Error("Account not found")
	}
	Bbalance, _ = strconv.Atoi(string(Bbalancebytes))

	X, err = strconv.Atoi(args[2])
	if err != nil {
		return shim.Error("Invalid transaction amount, expecting a integer value")
	}
	if X > Abalance {
		return shim.Error("Not sufficient funds")
	}
	Abalance = Abalance - X
	Bbalance = Bbalance + X
	fmt.Printf("Abalance = %d, Bbalance = %d\n", Abalance, Bbalance)

	// Write the state back to the ledger
	err = stub.PutState(Auser, []byte(strconv.Itoa(Abalance)))
	if err != nil {
		return shim.Error(err.Error())
	}

	err = stub.PutState(Buser, []byte(strconv.Itoa(Bbalance)))
	if err != nil {
		return shim.Error(err.Error())
	}

	return shim.Success(nil)
}

func (e *EWallet) queryAccount(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	var err error

	if len(args) != 1 {
		return shim.Error("Incorrect number of arguments. Expecting 1")
	}

	user := args[0]

	balancebytes, err := stub.GetState(user)
	if err != nil {
		jsonResp := "{\"Error\":\"Failed to get state for " + user + "\"}"
		return shim.Error(jsonResp)
	}

	if balancebytes == nil {
		jsonResp := "{\"Error\":\"Nil balance for " + user + "\"}"
		return shim.Error(jsonResp)
	}

	jsonResp := "{\"Name\":\"" + user + "\",\"Amount\":\"" + string(balancebytes) + "\"}"
	fmt.Printf("Query Response:%s\n", jsonResp)
	return shim.Success(balancebytes)
}

func (e *EWallet) deleteAccount(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	if len(args) != 1 {
		return shim.Error("Incorrect number of arguments. Expecting 1")
	}

	user := args[0]

	err := stub.DelState(user)
	if err != nil {
		return shim.Error("Failed to delete state")
	}

	return shim.Success(nil)
}

func (e *EWallet) saveMoney(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	var balance int
	if len(args) != 2 {
		return shim.Error("Incorrect number of arguments. Expecting 2")
	}

	user := args[0]

	balancebytes, err := stub.GetState(user)
	if err != nil {
		return shim.Error("Failed to get state")
	}
	if balancebytes == nil {
		e.createAccount(stub, []string{user})
	}
	balance, _ = strconv.Atoi(string(balancebytes))

	X, err := strconv.Atoi(args[1])
	if err != nil {
		return shim.Error("Invalid transaction amount, expecting a integer value")
	}

	balance = balance + X
	fmt.Printf("balance = %d\n", balance)

	// Write the state back to the ledger
	err = stub.PutState(user, []byte(strconv.Itoa(balance)))
	if err != nil {
		return shim.Error(err.Error())
	}

	return shim.Success(nil)
}

func (e *EWallet) drawMoney(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	var balance int
	if len(args) != 2 {
		return shim.Error("Incorrect number of arguments. Expecting 2")
	}

	user := args[0]

	balancebytes, err := stub.GetState(user)
	if err != nil {
		return shim.Error("Failed to get state")
	}
	if balancebytes == nil {
		return shim.Error("Account not found")
	}
	balance, _ = strconv.Atoi(string(balancebytes))

	X, err := strconv.Atoi(args[1])
	if err != nil {
		return shim.Error("Invalid transaction amount, expecting a integer value")
	}
	if X > balance {
		return shim.Error("Not sufficient funds")
	}

	balance = balance - X
	fmt.Printf("balance = %d\n", balance)

	// Write the state back to the ledger
	err = stub.PutState(user, []byte(strconv.Itoa(balance)))
	if err != nil {
		return shim.Error(err.Error())
	}

	return shim.Success(nil)
}

func (e *EWallet) queryAllAccounts(stub shim.ChaincodeStubInterface, args []string) pb.Response {

	if len(args) != 0 {
		return shim.Error("Incorrect number of arguments. Expecting 0")
	}

	startKey := "a"
	endKey := "zzzzzz"

	resultsIterator, err := stub.GetStateByRange(startKey, endKey)
	if err != nil {
		return shim.Error(err.Error())
	}
	defer resultsIterator.Close()

	// buffer is a JSON array containing QueryResults
	var buffer bytes.Buffer
	buffer.WriteString("[")

	bArrayMemberAlreadyWritten := false
	for resultsIterator.HasNext() {
		queryResponse, err := resultsIterator.Next()
		if err != nil {
			return shim.Error(err.Error())
		}
		// Add a comma before array members, suppress it for the first array member
		if bArrayMemberAlreadyWritten == true {
			buffer.WriteString(",")
		}
		buffer.WriteString("{\"USER\":")
		buffer.WriteString("\"")
		buffer.WriteString(queryResponse.Key)
		buffer.WriteString("\"")

		buffer.WriteString(", \"BALANCE\":")
		// Record is a JSON object, so we write as-is
		buffer.WriteString(string(queryResponse.Value))
		buffer.WriteString("}")
		bArrayMemberAlreadyWritten = true
	}
	buffer.WriteString("]")

	fmt.Printf("- queryResult:\n%s\n", buffer.String())

	return shim.Success(buffer.Bytes())
}

func (e *EWallet) getHistoryForAccount(stub shim.ChaincodeStubInterface, args []string) pb.Response {

	if len(args) != 1 {
		return shim.Error("Incorrect number of arguments. Expecting 1")
	}

	user := args[0]

	fmt.Printf("- start getHistoryForAccount: %s\n", user)

	resultsIterator, err := stub.GetHistoryForKey(user)
	if err != nil {
		return shim.Error(err.Error())
	}
	defer resultsIterator.Close()

	var buffer bytes.Buffer
	buffer.WriteString("[")

	bArrayMemberAlreadyWritten := false
	for resultsIterator.HasNext() {
		response, err := resultsIterator.Next()
		if err != nil {
			return shim.Error(err.Error())
		}
		// Add a comma before array members, suppress it for the first array member
		if bArrayMemberAlreadyWritten == true {
			buffer.WriteString(",")
		}
		buffer.WriteString("{\"TxId\":")
		buffer.WriteString("\"")
		buffer.WriteString(response.TxId)
		buffer.WriteString("\"")

		buffer.WriteString(", \"USER\":")
		buffer.WriteString(user)

		buffer.WriteString(", \"BALANCE\":")
		buffer.WriteString(string(response.Value))
		// if it was a delete operation on given key, then we need to set the
		//corresponding value null. Else, we will write the response.Value
		//as-is (as the Value itself a JSON marble)
		//		if response.IsDelete {
		//			buffer.WriteString("null")
		//		} else {
		//			buffer.WriteString(string(response.Value))
		//		}

		buffer.WriteString(", \"Timestamp\":")
		buffer.WriteString("\"")
		buffer.WriteString(time.Unix(response.Timestamp.Seconds, int64(response.Timestamp.Nanos)).String())
		buffer.WriteString("\"")

		//		buffer.WriteString(", \"IsDelete\":")
		//		buffer.WriteString("\"")
		//		buffer.WriteString(strconv.FormatBool(response.IsDelete))
		//		buffer.WriteString("\"")

		buffer.WriteString("}")
		bArrayMemberAlreadyWritten = true
	}
	buffer.WriteString("]")

	fmt.Printf("- getHistoryForAccount returning:\n%s\n", buffer.String())

	return shim.Success(buffer.Bytes())
}

func main() {
	err := shim.Start(new(EWallet))
	if err != nil {
		fmt.Printf("Error starting E-Wallet: %s", err)
	}
}
