// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;

contract baby_bank {
    mapping(address => uint256) public balance;
    mapping(address => uint256) public withdrawTime;
    mapping(address => bytes32) public userHash;

    event UserSignup(address indexed user, bytes32 nameHash);
    event Deposit(address indexed from, address indexed to, uint256 amount, uint256 lockTime);
    event Withdrawal(address indexed user, uint256 amount, uint256 gift);

    constructor() payable {}

    modifier onlyRegistered() {
        require(userHash[msg.sender] != 0, "User not registered");
        _;
    }

    function signup(string calldata _name) public {
        if (userHash[msg.sender] != 0) {
            return;
        }
        userHash[msg.sender] = keccak256(abi.encodePacked((_name)));
        withdrawTime[msg.sender] = type(uint256).max;
        emit UserSignup(msg.sender, userHash[msg.sender]);
    }

    function deposit(uint256 _lockTime, address _recipient, string calldata _recipientName)
        public
        payable
        onlyRegistered
    {
        require(userHash[_recipient] == keccak256(abi.encodePacked((_recipientName))), "Invalid recipient");

        withdrawTime[_recipient] = block.number + _lockTime;
        balance[_recipient] = msg.value;
        emit Deposit(msg.sender, _recipient, msg.value, _lockTime);
    }

    function withdraw() public {
        if (balance[msg.sender] == 0) {
            return;
        }
        uint256 gift = 0;
        uint256 lucky = 0;

        if (block.number > withdrawTime[msg.sender]) {
            // VULN: bad randomness (preserved)
            lucky = uint256(keccak256(abi.encodePacked(block.number, msg.sender))) % 10;
            if (lucky == 0) {
                gift = (10 ** 15) * withdrawTime[msg.sender];
            }
        }
        uint256 amount = balance[msg.sender] + gift;
        balance[msg.sender] = 0;
        // VULN: potential reentrancy (preserved)
        msg.sender.transfer(amount);
        emit Withdrawal(msg.sender, amount, gift);
    }
}
