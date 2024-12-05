// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma abicoder v2;

contract MockBabyBank {
    mapping(address => uint256) public balance;
    mapping(address => uint256) public withdrawTime;
    mapping(address => bytes32) public user;

    constructor() payable {}

    function signup(string calldata _n) public {
        user[msg.sender] = keccak256(abi.encodePacked(_n));
        withdrawTime[msg.sender] = type(uint256).max;
    }

    function deposit(uint256 _t, address _tg, string calldata _n) public payable {
        require(user[msg.sender] != 0, "User not signed up");
        require(user[_tg] == keccak256(abi.encodePacked(_n)), "Invalid target user");
        require(_tg == msg.sender, "Can only deposit to own account");

        withdrawTime[_tg] = block.number + _t;
        balance[_tg] += msg.value;
    }

    function withdraw() public {
        uint256 amount = balance[msg.sender];
        require(amount > 0, "No balance to withdraw");

        uint256 gift = 0;
        uint256 lucky = uint256(keccak256(abi.encodePacked(block.number, msg.sender))) % 10;

        if (block.number > withdrawTime[msg.sender] && lucky == 0) {
            gift = (10 ** 15) * withdrawTime[msg.sender];
        }

        balance[msg.sender] = 0;

        (bool success,) = payable(msg.sender).call{value: amount + gift}("");
        require(success, "Transfer failed");
    }

    // Additional functions for testing
    function getBalance(address _user) public view returns (uint256) {
        return balance[_user];
    }

    function getWithdrawTime(address _user) public view returns (uint256) {
        return withdrawTime[_user];
    }

    function getUserHash(address _user) public view returns (bytes32) {
        return user[_user];
    }
}
