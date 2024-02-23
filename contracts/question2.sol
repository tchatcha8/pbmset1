// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract Faucet {
    // Maximum amount which can be withdrawn
    uint public constant MAX_AMOUNT = 1 ether;

    // Enable the contract to receive funds
    receive() external payable {}

    // Allow anyone to withdraw from the contract up to MAX_AMOUNT
    function withdraw(uint withdraw_amount) public {
        require(withdraw_amount <= MAX_AMOUNT, "Withdrawal amount is higher than the maximum allowed");
        require(address(this).balance >= withdraw_amount, "Insufficient amount in faucet for withdrawal request");

        payable(msg.sender).transfer(withdraw_amount);
    }
}