// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;
pragma abicoder v2;

import "forge-std/Test.sol";
import "../contracts/baby_bank.sol";

contract BabyBankTest is Test {
    baby_bank public bank;
    address public alice = address(0x1);
    address public bob = address(0x2);

    function setUp() public {
        bank = new baby_bank();
        vm.deal(alice, 10 ether);
        vm.deal(bob, 10 ether);
    }

    function testSignup() public {
        vm.prank(alice);
        bank.signup("Alice");
        assertEq(bank.user(alice), keccak256(abi.encodePacked("Alice")));
    }

    function testDeposit() public {
        vm.startPrank(alice);
        bank.signup("Alice");
        bank.deposit{value: 1 ether}(100, alice, "Alice");
        vm.stopPrank();

        assertEq(bank.balance(alice), 1 ether);
        assertEq(bank.withdraw_time(alice), block.number + 100);
    }

    function testWithdraw() public {
        vm.startPrank(alice);
        bank.signup("Alice");
        bank.deposit{value: 1 ether}(100, alice, "Alice");
        vm.roll(block.number + 101);
        uint256 balanceBefore = alice.balance;
        bank.withdraw();
        vm.stopPrank();

        assertEq(bank.balance(alice), 0);
        assertGt(alice.balance, balanceBefore);
    }

    function testFailWithdrawTooEarly() public {
        vm.startPrank(alice);
        bank.signup("Alice");
        bank.deposit{value: 1 ether}(100, alice, "Alice");
        bank.withdraw();
        vm.stopPrank();
    }
}
