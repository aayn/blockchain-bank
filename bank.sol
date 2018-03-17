pragma solidity ^0.4.18;

contract Bank {
    event AddedAccount(uint accNo);

    struct Account {
        uint balance;
        uint accNo;
    }

    struct AccountHolder {
        string name;
        Account account;  
    }

    uint numAccounts;

    mapping (uint => Account) accounts;
    mapping (uint => AccountHolder) accHolders;
    
    /* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
     *  These functions perform transactions, editing the mappings *
     * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

    function addAccount(string name) public {
        // candidateID is the return variable
        uint accNo = numAccounts++;

        accounts[accNo] = Account(100, accNo);
        accHolders[accNo] = AccountHolder(name, accounts[accNo]);

        AddedAccount(accNo);
    }

    /* * * * * * * * * * * * * * * * * * * * * * * * * * 
     *  Getter Functions, marked by the key word "view" *
     * * * * * * * * * * * * * * * * * * * * * * * * * */
    
    function showAccount(uint accNo) view public returns (uint, uint) {
        return (accounts[accNo].balance, accounts[accNo].accNo);
    }

    function showAccHolderInfo(uint accNo) view public returns (string, uint) {
        return (accHolders[accNo].name, accHolders[accNo].account.accNo);
    }

    function getNumAccounts() public view returns(uint) {
        return numAccounts;
    }
}