// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.6;
pragma abicoder v2;

import "forge-std/Test.sol";
import "./baby_bank.sol";

contract baby_bankTest is Test {
    baby_bank bank;
    address user1 = address(0x123);
    address user2 = address(0x456);
    uint256 initialDeposit = 1 ether;

    function setUp() public {        
        bank = new baby_bank();
    }

    function testSignup() public {        
        bank.signup("Alice");
        bytes32 userHash = keccak256(abi.encodePacked("Alice"));
        assertEq(bank.user(address(this)), userHash);
    }

    function testDeposit() public {
        bank.signup("Alice");
        bank.signup("Bob");

        // Depositar fondos desde una cuenta
        vm.deal(address(this), initialDeposit); // Dar fondos a la cuenta de prueba
        bank.deposit{value: initialDeposit}(100, address(this), "Alice");

        // Verificar el balance y el tiempo de retiro
        assertEq(bank.balance(address(this)), initialDeposit);
        assertEq(bank.withdraw_time(address(this)), block.number + 100);
    }

    function testWithdraw() public {
        
        bank.signup("Alice");
        vm.deal(address(this), initialDeposit);
        bank.deposit{value: initialDeposit}(50, address(this), "Alice");

        vm.roll(block.number + 51);        
        uint256 prevBalance = address(this).balance;
        bank.withdraw();
        uint256 newBalance = address(this).balance;

        assertGt(newBalance, prevBalance);
        assertEq(bank.balance(address(this)), 0);
    }

    function testFailWithdrawBeforeTime() public {
        
        bank.signup("Alice");
        vm.deal(address(this), initialDeposit);
        bank.deposit{value: initialDeposit}(100, address(this), "Alice");

        
        vm.expectRevert();
        bank.withdraw();
    }
}
