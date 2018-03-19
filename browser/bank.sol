pragma solidity ^0.4.18;
import "browser/payment_standard.sol";


contract Bank {
    event AccountCreated(address);
    event TransferSuccessful(address, address);

    // address private creator;
    uint minBal = 50;
    uint private numAccounts;

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

    function deposit() external payable accountExistsGuard(true) {
        accounts[msg.sender].balance += msg.value;
    }

    function isJointAcc(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }

    function withdraw(uint amount) external accountExistsGuard(true) balanceGuard(amount) {
        if (isJointAcc(msg.sender)) {
            JointAccount ja = JointAccount(msg.sender);
            ja.receive.value(amount)();
        } else {
            msg.sender.transfer(amount);
        }
        accounts[msg.sender].balance -= amount;
    }


    function transfer(uint amount, address toAddr) external accountExistsGuard(true) balanceGuard(amount) recepientGuard(toAddr) {
        accounts[msg.sender].balance -= amount;
        accounts[toAddr].balance += amount;
        //emit TransferSuccessful(msg.sender, toAddr);
    }


    /* * * * * * * * * * * * * * * * * * * * * * * * * * 
     *  Getter Functions, marked by the key word "view" *
     * * * * * * * * * * * * * * * * * * * * * * * * * */

    function showAccount() view external accountExistsGuard(true) returns (uint, address) {
        return (accounts[msg.sender].balance, msg.sender);
    }

    function getNumAccounts() public view returns(uint) {
        return numAccounts;
    }
    
    function showBankAddress() view public returns(address) {
        return this;
    }

}


contract JointAccount {
    address[] owners;
    mapping (address => bool) approvals;
    Bank bank;

    function JointAccount(address[] _owners, address bankAddr) public {
        owners.push(msg.sender);
        for (uint8 i = 0; i < _owners.length; i++) {
            owners.push(_owners[i]);
        }
        bank = Bank(bankAddr);
    }

    function approve() public {
        approvals[msg.sender] = true;
    }

    function allApprove() internal view returns (bool) {
        for (uint8 i = 0; i < owners.length; i++) {
            if (approvals[owners[i]] == false)
                return false;
        }
        return true;
    }

    modifier approveGuard() {
        require(allApprove());
        _;
    }

    function resetApprovals() private {
        for (uint8 i = 0; i < owners.length; i++) {
            approvals[owners[i]] = false;
        }
    }

    function registerAccount() public payable approveGuard {
        bank.createAccount.value(msg.value)();
        resetApprovals();
    }

    function deposit() external payable {
        bank.deposit.value(msg.value)();
    }

    function withdraw(uint amount) external {
        bank.withdraw(amount);
        msg.sender.transfer(amount);
    }

    function transfer(uint amount, address toAddr) external {
        bank.transfer(amount, toAddr);
    }

    function receive() public payable {}

    function deleteAccount() public approveGuard {
        bank.deleteAccount();
    }

    function showAccount() external view returns (uint, address) {
        return bank.showAccount();
    }

    function viewAddress() public view returns(address) {
        return this;
    }
}