// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "forge-std/StdMath.sol";
import "forge-std/console.sol";

contract baby_bank {
    using stdMath for uint256; // Still use stdMath for other functions like delta, abs

    mapping(address => uint256) public balance;
    mapping(address => uint256) public withdraw_time;
    mapping(address => bytes32) public user;

    constructor() payable {}

    function signup(string calldata _n) public {
        if (user[msg.sender] != 0) {
            return;
        }
        user[msg.sender] = keccak256(abi.encodePacked((_n)));
        withdraw_time[msg.sender] = type(uint256).max;
        console.log("User signed up:", _n);
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
        console.log("Deposit made by:", msg.sender);
        console.log("Balance updated for:", _tg, " with value: ", msg.value);
    }

    function withdraw() public {
        if (balance[msg.sender] == 0) {
            return;
        }
        uint256 gift = 0;
        uint256 lucky = 0;

        if (block.number > withdraw_time[msg.sender]) {
            lucky = uint256(keccak256(abi.encodePacked(block.number, msg.sender))) % 10;
            if (lucky == 0) {
                gift = (10 ** 15) * max(withdraw_time[msg.sender], 100); // Using the custom max function
            }
            console.log("Lucky number:", lucky, "Calculated gift:", gift);
        }
        uint256 amount = balance[msg.sender] + gift;
        balance[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
        console.log("User", msg.sender, "has withdrawn", amount);
    }

    // Custom max function
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    // Custom min function (if needed)
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a <= b ? a : b;
    }
}
