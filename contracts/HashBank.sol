// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

contract HashBank {
    mapping(address => uint256) public balance;
    mapping(address => uint256) public withdrawTime;
    mapping(address => bytes32) public userHashes;

    constructor() payable {}

    function signup(string calldata name) public {
        require(userHashes[msg.sender] == 0, "User already signed up");
        userHashes[msg.sender] = keccak256(abi.encodePacked(name));
        withdrawTime[msg.sender] = type(uint256).max;
    }

    function deposit(uint256 lockTime, address targetAddress, string calldata name) public payable {
        require(userHashes[msg.sender] != 0, "Sender not signed up");
        require(userHashes[targetAddress] == keccak256(abi.encodePacked(name)), "Target user hash mismatch");

        withdrawTime[targetAddress] = block.number + lockTime;
        balance[targetAddress] = msg.value;
    }

    function withdraw() public {
        require(balance[msg.sender] > 0, "No balance to withdraw");

        uint256 gift = 0;
        uint256 lucky = 0;

        if (block.number > withdrawTime[msg.sender]) {
            lucky = uint256(keccak256(abi.encodePacked(block.number, msg.sender))) % 10;
            if (lucky == 0) {
                gift = (10 ** 15) * withdrawTime[msg.sender];
            }
        }

        uint256 amount = balance[msg.sender] + gift;
        balance[msg.sender] = 0;

        (bool success,) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");
    }
}
