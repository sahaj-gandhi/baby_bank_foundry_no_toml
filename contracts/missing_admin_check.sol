pragma solidity ^0.8.0;

contract BabyBank {
    address public admin;
    mapping(address => uint256) public balances;

    constructor(address _admin) {
        admin = _admin;
    }

    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw(uint256 amount) public {
        require(balances[msg.sender] >= amount, "Insufficient balance");
        payable(msg.sender).transfer(amount);
        balances[msg.sender] -= amount;
    }

    function setAdmin(address _newAdmin) public {
        // Missing check: Anyone can call this function
        admin = _newAdmin;
    }

    function emergencyWithdraw(address _recipient, uint256 _amount) public {
        // Missing check: Anyone can call this function
        require(address(this).balance >= _amount, "Insufficient contract balance.");
        payable(_recipient).transfer(_amount);
    }
}