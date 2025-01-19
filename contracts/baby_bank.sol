// SPDX-License-Identifier: UNKNOWN
pragma solidity ^0.7.6;

import "./parent_bank.sol";

contract baby_bank is ParentBank {
    mapping(address => uint256) public withdraw_time;
    mapping(address => bytes32) public user;

    constructor() payable {}

    function signup(string calldata _n) public {
        if (user[msg.sender] != 0) {
            return;
        }
        user[msg.sender] = keccak256(abi.encodePacked((_n)));
        withdraw_time[msg.sender] = (2 ** 256) - 2;
    }

    function deposit(uint256 _t, address _tg, string calldata _n) public payable {
        if (user[msg.sender] == 0) {
            revert();
        }

        if (user[_tg] != keccak256(abi.encodePacked((_n)))) {
            revert();
        }

        withdraw_time[_tg] = block.number + _t;
        balance[_tg] = msg.value;
    }

    function withdraw() public override {
        super.withdraw();

        uint256 gift = 0;
        uint256 lucky = 0;

        if (block.number > withdraw_time[msg.sender]) {
            // VULN: bad randomness
            lucky = uint256(keccak256(abi.encodePacked(block.number, msg.sender))) % 10;
            if (lucky == 0) {
                gift = (10 ** 12) * withdraw_time[msg.sender];
            }
        }

        if (gift > 0) {
            payable(msg.sender).transfer(gift);
        }

        withdraw_time[msg.sender] = 0;
    }
}
