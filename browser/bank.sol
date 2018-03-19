pragma solidity ^0.4.18;
import "browser/payment_standard.sol";


contract Bank is PaymentStandard {
    event AccountCreated(address);
    event TransferSuccessful(address, address);

    uint private minBal = 50;
    uint private numAccounts;
    uint private depositLim = 10 ether;
    uint private transferLim = 7 ether;
    uint private withdrawLim = 5 ether;


    struct Account {
        uint balance;
        bool exists;
    }

    mapping (address => Account) accounts;

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

     modifier limitGuard(uint amount, uint limit) {
         require(amount <= limit);
         _;
     }


    function createAccount() public payable accountExistsGuard(false) {
        accounts[msg.sender] = Account(msg.value, true);
        numAccounts++;
        emit AccountCreated(msg.sender);
    }

    function deleteAccount() public accountExistsGuard(true) {
        delete accounts[msg.sender];
        numAccounts--;
    }

    function deposit() external payable accountExistsGuard(true) limitGuard(msg.value, depositLim) {
        accounts[msg.sender].balance += msg.value;
    }

    function isJointAcc(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }

    function withdraw(uint amount) external accountExistsGuard(true) balanceGuard(amount) limitGuard(amount, withdrawLim) {
        if (isJointAcc(msg.sender)) {
            JointAccount ja = JointAccount(msg.sender);
            ja.receive.value(amount)();
        } else {
            msg.sender.transfer(amount);
        }
        accounts[msg.sender].balance -= amount;
    }


    function transfer(uint amount, address toAddr) external accountExistsGuard(true) balanceGuard(amount) recepientGuard(toAddr) limitGuard(amount, depositLim) {
        accounts[msg.sender].balance -= amount;
        accounts[toAddr].balance += amount;
        emit TransferSuccessful(msg.sender, toAddr);
    }

    /* Getter Functions */

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
    mapping (address => bool) exists;
    mapping (address => bool) approvals;
    Bank bank;

    function JointAccount(address[] _owners, address bankAddr) public {
        owners.push(msg.sender);
        exists[msg.sender] = true;
        for (uint8 i = 0; i < _owners.length; i++) {
            owners.push(_owners[i]);
            exists[_owners[i]] = true;
        }
        bank = Bank(bankAddr);
    }

    function approve() public ownerGuard {
        approvals[msg.sender] = true;
    }

    function allApprove() internal view returns (bool) {
        for (uint8 i = 0; i < owners.length; i++) {
            if (approvals[owners[i]] == false)
                return false;
        }
        return true;
    }

    modifier ownerGuard() {
        require(exists[msg.sender]);
        _;
    }

    modifier approveGuard() {
        require(allApprove());
        _;
    }

    function resetApprovals() internal {
        for (uint8 i = 0; i < owners.length; i++) {
            approvals[owners[i]] = false;
        }
    }

    function registerAccount() public payable ownerGuard approveGuard {
        bank.createAccount.value(msg.value)();
        resetApprovals();
    }

    function deposit() external payable ownerGuard {
        bank.deposit.value(msg.value)();
    }

    function withdraw(uint amount) external ownerGuard {
        bank.withdraw(amount);
        msg.sender.transfer(amount);
    }

    function transfer(uint amount, address toAddr) external ownerGuard {
        bank.transfer(amount, toAddr);
    }

    function receive() public payable {}

    function deleteAccount() public ownerGuard approveGuard {
        bank.deleteAccount();
    }

    /* Getter Functions */


    function showAccount() external view ownerGuard returns (uint, address) {
        return bank.showAccount();
    }

    function viewAddress() public view ownerGuard returns(address) {
        return this;
    }
}