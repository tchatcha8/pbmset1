// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract ExtendedFaucet {
    address public owner;
    uint public constant MAX_AMOUNT = 1 ether;
    uint public constant MAX_USERS = 4;
    address[] public withdrawnUsers;

    constructor() {
        owner = msg.sender; // The contract creator is the owner
    }

    modifier onlyOwner {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    // Enable the contract to receive funds
    receive() external payable {}

    function withdraw(uint withdraw_amount) public {
        require(withdraw_amount <= MAX_AMOUNT, "Withdrawal amount exceeds the maximum allowed");
        require(address(this).balance >= withdraw_amount, "Insufficient amount in faucet for withdrawal request");
        require(withdrawnUsers.length < MAX_USERS || isExistingUser(msg.sender), "Maximum number of unique users reached or user already withdrawn");

        if (!isExistingUser(msg.sender)) {
            withdrawnUsers.push(msg.sender);
        }

        payable(msg.sender).transfer(withdraw_amount);
    }

    function isExistingUser(address user) internal view returns (bool) {
        for (uint i = 0; i < withdrawnUsers.length; i++) {
            if (withdrawnUsers[i] == user) {
                return true;
            }
        }
        return false;
    }

    function resetUsers() public onlyOwner {
        // Reset the list of users who have withdrawn
        delete withdrawnUsers;
    }


}