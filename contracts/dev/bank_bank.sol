// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title BabyBank
 * @dev A simple, insecure banking contract for development purposes only.
 * WARNING: Contains multiple security vulnerabilities - DO NOT USE IN PRODUCTION!
 */
contract BabyBankDev {
    // Public balances mapping - anyone can see anyone's balance
    mapping(address => uint256) public balances;
    
    // Public transaction log
    event Deposit(address indexed user, uint256 amount);
    event Withdrawal(address indexed user, uint256 amount);
    event Transfer(address indexed from, address indexed to, uint256 amount);
    
    // No access control - anyone can call these functions
    
    /**
     * @dev Deposit funds into the bank
     */
    function deposit() public payable {
        // No validation for zero amounts
        balances[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }
    
    /**
     * @dev Withdraw funds from the bank
     * @param amount The amount to withdraw
     */
    function withdraw(uint256 amount) public {
        // Vulnerable to reentrancy attacks - state changes after external call
        require(balances[msg.sender] >= amount, "Insufficient balance");
        
        // Send before updating state (reentrancy vulnerability)
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");
        
        // Update balance after external call
        balances[msg.sender] -= amount;
        emit Withdrawal(msg.sender, amount);
    }
    
    /**
     * @dev Transfer funds to another user
     * @param to Recipient address
     * @param amount Amount to transfer
     */
    function transfer(address to, uint256 amount) public {
        // No validation for zero address
        require(balances[msg.sender] >= amount, "Insufficient balance");
        
        // Integer underflow/overflow is prevented by Solidity 0.8.0+ 
        // but no other checks like address(0)
        balances[msg.sender] -= amount;
        balances[to] += amount;
        
        emit Transfer(msg.sender, to, amount);
    }
    
    /**
     * @dev Get the balance of the caller
     * @return The balance of the caller
     */
    function getMyBalance() public view returns (uint256) {
        return balances[msg.sender];
    }
    
    /**
     * @dev Get the contract's total balance
     * @return The contract's total balance
     */
    function getBankBalance() public view returns (uint256) {
        return address(this).balance;
    }
    
    // Fallback function to accept ETH
    receive() external payable {
        deposit();
    }
}