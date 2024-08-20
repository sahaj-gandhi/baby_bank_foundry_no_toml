// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract BabyBank {
    mapping(address => uint256) public balance;
    mapping(address => uint256) public withdrawTime;
    mapping(address => bytes32) public user;

    event Signup(address indexed user, bytes32 nameHash);
    event Deposit(address indexed from, address indexed to, uint256 amount, uint256 unlockTime);
    event Withdraw(address indexed user, uint256 amount, uint256 gift);

    constructor() payable {}

    function signup(string calldata _name) external {
        require(user[msg.sender] == bytes32(0), "User already signed up");
        user[msg.sender] = keccak256(abi.encodePacked(_name));
        withdrawTime[msg.sender] = type(uint256).max;
        emit Signup(msg.sender, user[msg.sender]);
    }

    // hello

    function deposit(uint256 _time, address _target, string calldata _name) external payable {
        require(user[msg.sender] != bytes32(0), "Sender not signed up");
        require(user[_target] == keccak256(abi.encodePacked(_name)), "Target name does not match");

        withdrawTime[_target] = block.timestamp + _time;
        balance[_target] += msg.value; // Allow multiple deposits to accumulate

        emit Deposit(msg.sender, _target, msg.value, withdrawTime[_target]);
    }

    function withdraw() external {
        require(balance[msg.sender] > 0, "No balance to withdraw");
        uint256 amount = balance[msg.sender];
        uint256 gift = 0;

        if (block.timestamp > withdrawTime[msg.sender]) {
            // Generate a pseudo-random number using keccak256
            uint256 lucky = uint256(keccak256(abi.encodePacked(blockhash(block.number - 1), msg.sender))) % 10;
            if (lucky == 0) {
                gift = (10 ** 15) * withdrawTime[msg.sender];
            }
        }

        balance[msg.sender] = 0;
        uint256 totalAmount = amount + gift;

        (bool success,) = msg.sender.call{value: totalAmount}("");
        require(success, "Transfer failed");

        emit Withdraw(msg.sender, amount, gift);
    }

    receive() external payable {}
}
