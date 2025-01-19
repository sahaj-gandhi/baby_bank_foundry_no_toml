// SPDX-License-Identifier: UNKNOWN
pragma solidity ^0.7.6;

contract ParentBank {
    mapping(address => uint256) public balance;

    function withdraw() public virtual {
        require(balance[msg.sender] > 0, "No balance to withdraw");
        uint256 amount = balance[msg.sender];
        balance[msg.sender] = 0;
        balance[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
    }
}
