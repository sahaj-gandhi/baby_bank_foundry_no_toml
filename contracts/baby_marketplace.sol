// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./baby_bank.sol";
import "./baby_invetory.sol";

contract BabyMarketplace {
    BabyBank private babyBank;
    BabyInventory private babyInventory;

    constructor(address _babyBankAddress, address _babyInventoryAddress) {
        babyBank = BabyBank(_babyBankAddress);
        babyInventory = BabyInventory(_babyInventoryAddress);
    }

    event ItemPurchased(
        address indexed buyer, address indexed seller, uint256 indexed itemId, uint256 quantity, uint256 totalPrice
    );

    function purchaseItem(address _seller, uint256 _itemId, uint256 _quantity) public {
        // Verificar que el ítem existe y obtener sus detalles
        (, uint256 itemQuantity, uint256 itemPrice) = babyInventory.getItem(_seller, _itemId);
        require(_quantity > 0, "Quantity must be greater than zero");
        require(_quantity <= itemQuantity, "Not enough items in stock");

        uint256 totalPrice = itemPrice * _quantity;

        require(babyBank.balance(msg.sender) >= totalPrice, "Insufficient balance");

        babyBank.updateBalance(msg.sender, totalPrice, false); // False indica que es una deducción
        babyBank.updateBalance(_seller, totalPrice, true); // True indica que es un incremento

        emit ItemPurchased(msg.sender, _seller, _itemId, _quantity, totalPrice);
    }
}
