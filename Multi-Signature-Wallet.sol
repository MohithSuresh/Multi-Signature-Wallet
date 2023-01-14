// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.4;

contract MultiSignatureWallet {
    // Array of owners
    address[] public owners;
    uint256 public requiredNumberOfConfirmtions;
    Transaction[] public transactions;
    mapping(uint256 => mapping(address => bool)) confirmations;
    mapping(address => bool) isOwner;
    mapping(uint256 => uint256) public numberOfConfirmations;

    struct Transaction {
        address to;
        uint256 value;
        bytes data;
        bool executed;
        uint256 numberOfConfirmations;
    }

    constructor(
        address[] memory _owners,
        uint256 _requiredNumberOfConfirmtions
    ) {
        for (uint256 i = 0; i < _owners.length; i++) {
            require(_owners[i] != address(0), "Invalid owner");
            require(!isOwner[_owners[i]], "Owner not unique");
            isOwner[_owners[i]] = true;
            owners.push(_owners[i]);
        }
        require(
            _requiredNumberOfConfirmtions <= owners.length,
            "Required number of confirmations should be less than or equal to the number of owners"
        );
        require(
            _requiredNumberOfConfirmtions > 0,
            "Required number of confirmations should be greater than 0"
        );
        requiredNumberOfConfirmtions = _requiredNumberOfConfirmtions;
    }

    //submitTransaction
    function submitTransaction(
        Transaction memory _transaction
    ) public returns (bool) {
        transactions.push(_transaction);
        return true;
    }

    //confirmTransaction
    function confirmTransaction(
        uint256 _transactionId
    )
        public
        OnlyOwner
        TxnExists(_transactionId)
        TxnNotExecuted(_transactionId)
        TxnNotConfirmed(_transactionId)
        returns (bool)
    {
        //add the sender to the senders of the transaction

        //increment the number of confirmations of the transaction
        numberOfConfirmations[_transactionId] += 1;
        //confirm transaction
        confirmations[_transactionId][msg.sender] = true;
    }

    //revokeConfirmation

    //check if the transaction exists
    modifier TxnExists(uint256 _transactionId) {
        require(
            _transactionId < transactions.length,
            "Transaction does not exist"
        );
        _;
    }

    //check if the sender is an owner
    modifier OnlyOwner() {
        require(isOwner[msg.sender], "Sender is not an owner");
        _;
    }
    //check if the transaction has not been executed
    modifier TxnNotExecuted(uint256 _transactionId) {
        require(
            !transactions[_transactionId].executed,
            "Transaction has been executed"
        );
        _;
    }
    //check if the sender has not confirmed the transaction
    modifier TxnNotConfirmed(uint256 _transactionId) {
        require(
            !confirmations[_transactionId][msg.sender],
            "Transaction has been confirmed"
        );
        _;
    }
}
