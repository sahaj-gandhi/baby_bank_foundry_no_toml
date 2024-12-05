// SPDX-License-Identifier: MIT pragma solidity ^0.7.6;

contract MockBabyBank {
    mapping(address => uint256) public balance;

mapping (address => uint256) public withdraw_time;

mapping (address => bytes32) public user;

constructor() payable {} 

    function signup(string calldata _n) public {
        user[msg.sender] = keccak256(abi.encodePacked((_n)));

withdraw_time[msg.sender] = type (uint256).max;

} 

    function deposit(uint256 _t, address _tg, string calldata _n) public payable {
        require(user[msg.sender] != 0, "User not signed up");

require (
    user [_tg] = = keccak256 (abi.encodePacked ((_n))),
    "Invalid target user"
);

withdraw_time[_tg] = block.number + _t;

balance[_tg] = msg.value;

} 

    function withdraw() public {
        require(balance[msg.sender] > 0, "No balance to withdraw");

uint256 gift = 0;

uint256 lucky = uint256 (
    keccak256 (
        abi.encodePacked (block.number, msg.sender)
    )
) % 10;

        if (block.number > withdraw_time[msg.sender] && lucky == 0) {
            gift = (10 ** 15) * withdraw_time[msg.sender];

} 

uint256 amount = balance[msg.sender] + gift;

balance[msg.sender] = 0;

payable (msg.sender).transfer (amount);

} 

    // Additional functions for testing
    function getBalance(address _user) public view returns (uint256) {
        return balance[_user];

} 

    function getWithdrawTime(address _user) public view returns (uint256) {
        return withdraw_time[_user];

} 

    function getUserHash(address _user) public view returns (bytes32) {
        return user[_user];

} } 