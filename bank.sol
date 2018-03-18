pragma solidity ^0.4.18;

contract Bank {
    event AccountCreated(address);
    event TransferSuccessful(address, address);

    address private creator; // The bank address
    uint minBal = 50;
    uint private numAccounts;

    function Bank() public {
        creator = msg.sender;
    }

    struct Account {
        uint balance;
        // string holderName;
        bool exists;
    }

    mapping (address => Account) accounts;

    /* * * * * * * * * * * * *
     *    Modifier Guards    *
     * * * * * * * * * * * * */

     modifier balanceGuard(uint amount) {
         require((amount + minBal) <= accounts[msg.sender].balance);
         _;
     }

     modifier recepientGuard(address addr) {
         require(accounts[addr].exists);
         _;
     }

     modifier accountExistsGuard(bool test) {
         require(accounts[msg.sender].exists == test);
         _;
     }

    
    /* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
     *  These functions perform transactions, editing the mappings *
     * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

    function createAccount() public payable accountExistsGuard(false) {
        accounts[msg.sender] = Account(msg.value, true);
        numAccounts++;
        // emit AccountCreated(msg.sender);
    }

    function deleteAccount() public accountExistsGuard(true) {
        delete accounts[msg.sender];
        numAccounts--;
    }

    function deposit() public payable accountExistsGuard(true) {
        accounts[msg.sender].balance += msg.value;
    }

    function withdraw(uint amount) public accountExistsGuard(true) balanceGuard(amount) {
        msg.sender.transfer(amount);
        accounts[msg.sender].balance -= amount;
    }

    function transfer(uint amount, address toAddr) public accountExistsGuard(true) balanceGuard(amount) recepientGuard(toAddr) {
        accounts[msg.sender].balance -= amount;
        accounts[toAddr].balance += amount;
        //emit TransferSuccessful(msg.sender, toAddr);
    }


    /* * * * * * * * * * * * * * * * * * * * * * * * * * 
     *  Getter Functions, marked by the key word "view" *
     * * * * * * * * * * * * * * * * * * * * * * * * * */

    function showAccount() view public accountExistsGuard(true) returns (uint, address) {
        return (accounts[msg.sender].balance, msg.sender);
    }

    function getNumAccounts() public view returns(uint) {
        return numAccounts;
    }
    
}