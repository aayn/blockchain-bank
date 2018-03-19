pragma solidity ^0.4.18;
import "browser/payment_standard.sol";


contract Bank is PaymentStandard {
    event AccountCreated(address);
    event TransferSuccessful(address, address);
    event DepositSuccessful(address);
    event WithdrawSuccessful(address);

    uint private minBal = 50;
    uint private numAccounts;
    uint private depositLim = 10 ether;
    uint private transferLim = 7 ether;
    uint private withdrawLim = 5 ether;


    struct AccountInfo {
        uint balance;
        bool exists;
    }

    mapping (address => AccountInfo) accounts;

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


    function registerAccount() external payable accountExistsGuard(false) {
        accounts[msg.sender] = AccountInfo(msg.value, true);
        numAccounts++;
        emit AccountCreated(msg.sender);
    }

    function deleteAccount() public accountExistsGuard(true) {
        delete accounts[msg.sender];
        numAccounts--;
    }

    function deposit() external payable accountExistsGuard(true) limitGuard(msg.value, depositLim) {
        accounts[msg.sender].balance += msg.value;
        emit DepositSuccessful(msg.sender);
    }

    function withdraw(uint amount) external accountExistsGuard(true) balanceGuard(amount) limitGuard(amount, withdrawLim) {
        Account acc = Account(msg.sender);
        acc.receive.value(amount)();
        accounts[msg.sender].balance -= amount;
        emit WithdrawSuccessful(msg.sender);
    }

    function transfer(uint amount, address toAddr) external accountExistsGuard(true) balanceGuard(amount) recepientGuard(toAddr) limitGuard(amount, transferLim) {
        accounts[msg.sender].balance -= amount;
        accounts[toAddr].balance += amount;
        emit TransferSuccessful(msg.sender, toAddr);
    }

    /* Getter Functions */

    function showAccount() view external accountExistsGuard(true) returns (uint, address) {
        return (accounts[msg.sender].balance, msg.sender);
    }

    function getNumAccounts() external view returns(uint) {
        return numAccounts;
    }
    
    function showBankAddress() view external returns(address) {
        return this;
    }

}


contract Account {
    address[] owners;
    mapping (address => bool) exists;
    mapping (address => bool) approvals;
    bool private jointAccount = false;
    Bank bank;

    function Account(address[] _owners, address bankAddr) public {
        owners.push(msg.sender);
        exists[msg.sender] = true;

        if (_owners.length > 0) {
            jointAccount = true;
            for (uint8 i = 0; i < _owners.length; i++) {
                owners.push(_owners[i]);
                exists[_owners[i]] = true;
            }
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
        if (jointAccount)
            require(allApprove());
        _;
    }

    function resetApprovals() internal {
        if (jointAccount) {
            for (uint8 i = 0; i < owners.length; i++) {
                approvals[owners[i]] = false;
            }
        }
    }

    function registerAccount() public payable ownerGuard approveGuard {
        bank.registerAccount.value(msg.value)();
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
        resetApprovals();
    }

    /* Getter Functions */


    function showAccount() external view ownerGuard returns (uint, address) {
        return bank.showAccount();
    }

    function viewAddress() public view ownerGuard returns(address) {
        return this;
    }
}