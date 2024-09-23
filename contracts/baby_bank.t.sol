// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.6;
pragma abicoder v2;

import "forge-std/Test.sol";
import "./baby_bank.sol"; // Asegúrate de que esta ruta sea correcta

contract baby_bankTest is Test {
    baby_bank bank;
    address user1 = address(0x123);
    address user2 = address(0x456);
    uint256 initialDeposit = 1 ether;

    function setUp() public {
        // Desplegar el contrato antes de cada prueba
        bank = new baby_bank();
    }

    function testSignup() public {
        // Registrar un usuario y verificar el estado
        bank.signup("Alice");
        bytes32 userHash = keccak256(abi.encodePacked("Alice"));
        assertEq(bank.user(address(this)), userHash);
    }

    function testDeposit() public {
        // Registrar usuarios
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
        // Registrar y depositar fondos
        bank.signup("Alice");
        vm.deal(address(this), initialDeposit);
        bank.deposit{value: initialDeposit}(50, address(this), "Alice");

        // Avanzar bloques para permitir el retiro
        vm.roll(block.number + 51);

        // Verificar el balance previo y retirar
        uint256 prevBalance = address(this).balance;
        bank.withdraw();
        uint256 newBalance = address(this).balance;

        assertGt(newBalance, prevBalance);
        assertEq(bank.balance(address(this)), 0);
    }

    function testFailWithdrawBeforeTime() public {
        // Registrar y depositar fondos
        bank.signup("Alice");
        vm.deal(address(this), initialDeposit);
        bank.deposit{value: initialDeposit}(100, address(this), "Alice");

        // Intentar retirar antes de que pase el tiempo
        vm.expectRevert();
        bank.withdraw(); // Esto debería fallar
    }
}
