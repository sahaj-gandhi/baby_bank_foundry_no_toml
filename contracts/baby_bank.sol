// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract BabyBank {
    mapping(address => uint256) public balance;
    mapping(address => uint256) public withdrawTime;
    mapping(address => bytes32) public user;

    constructor() payable {}

    function signup(string calldata _n) public {
        if (user[msg.sender] != 0) {
            return;
        }
        user[msg.sender] = keccak256(abi.encodePacked((_n)));
        withdrawTime[msg.sender] = type(uint256).max;
    }

    function deposit(uint256 _t, address _tg, string calldata _n) public payable {
        require(user[msg.sender] != 0, "User not signed up");
        require(user[_tg] == keccak256(abi.encodePacked((_n))), "Invalid target user");

        withdrawTime[_tg] = block.number + _t;
        balance[_tg] += msg.value;
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

    function updateBalance(address _user, uint256 _amount, bool _isCredit) public {
        if (_isCredit) {
            balance[_user] += _amount;
        } else {
            require(balance[_user] >= _amount, "Insufficient balance");
            balance[_user] -= _amount;
        }
    }
}
