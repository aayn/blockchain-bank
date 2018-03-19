pragma solidity ^0.4.18;

interface PaymentStandard {
    function deposit() external payable;
    function withdraw(uint) external;
    function transfer(uint, address) external;
    function showAccount() external view returns (uint, address);
}