// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract BabyBank {
    address public owner;
    uint256 public balance;

    constructor() {
        owner = msg.sender;
        balance = 0;
    }

    function deposit() public payable {
        balance += msg.value;
    }

    function withdraw(uint256 amount) public {
        require(msg.sender == owner, "Only owner can withdraw.");
        require(amount <= balance, "Insufficient balance.");
        payable(owner).transfer(amount);
        balance -= amount;
    }

    function getBalance() public view returns (uint256) {
        return balance;
    }
}