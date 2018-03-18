pragma solidity ^0.4.18;

contract Bank {
    event AddedAccount(uint accNo);
    event UserApplied(string name);

    address private creator; // The bank address
    uint minBal = 50;

    function Bank() public {
        creator = msg.sender;
    }

    struct Account {
        uint balance;
        uint accNo;
    }

    struct User {
        string name;
        address addr;
        // Account account;
    }

    uint numAccounts;
    uint numUsers;

    mapping (uint => Account) accounts;
    // mapping (address => Account) accounts;
    mapping (uint => User) applicants;
    mapping (uint => User) clients;

    /* * * * * * * * * * * * *
     *    Modifier Guards    *
     * * * * * * * * * * * * */

     modifier balanceGuard(uint curBal, uint amount) {
         require((amount + minBal) < curBal);
         _;
     }

     modifier addressGuard(address addr) {
         require(msg.sender == addr);
         _;
     }

    
    /* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
     *  These functions perform transactions, editing the mappings *
     * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

    function applyForAccount(string name) public {
        applicants[numUsers++ + 1] = User(name, msg.sender);
        // TODO: call userApplied event here
    }

    function approveAccount(uint uid) public addressGuard(creator) {
        
    
        accounts[uid] = Account(500, uid);
        numAccounts++;
        clients[uid] = applicants[uid];
        delete applicants[uid];
    }

    function removeApplicant(uint uid) public addressGuard(creator) {
        delete applicants[uid];        
    }

    function deposit(uint amount, uint accNo) public addressGuard(clients[accNo].addr) {

        accounts[accNo].balance += amount;
    }

    function withdraw(uint amount, uint accNo) public addressGuard(clients[accNo].addr) balanceGuard(accounts[accNo].balance, amount) {
        accounts[accNo].balance -= amount;        
    }


    /* * * * * * * * * * * * * * * * * * * * * * * * * * 
     *  Getter Functions, marked by the key word "view" *
     * * * * * * * * * * * * * * * * * * * * * * * * * */

    function showAccount(uint accNo) view public returns (uint, uint) {
        require(msg.sender == clients[accNo].addr || msg.sender == creator);
        
        return (accounts[accNo].balance, accounts[accNo].accNo);
    }

    function showClientInfo(uint accNo) view public returns (string, address) {
        require(msg.sender == clients[accNo].addr || msg.sender == creator);
        
        return (clients[accNo].name, clients[accNo].addr);
    }

    function getNumAccounts() public view returns(uint) {
        return numAccounts;
    }
    
}