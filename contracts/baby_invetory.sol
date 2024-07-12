// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract BabyInventory {
    struct Item {
        string name;
        uint256 quantity;
        uint256 price;
    }

    mapping(address => mapping(uint256 => Item)) public inventories;
    mapping(address => uint256) public itemCount;

    event ItemAdded(address indexed user, uint256 indexed itemId, string name, uint256 quantity, uint256 price);
    event ItemUpdated(address indexed user, uint256 indexed itemId, string name, uint256 quantity, uint256 price);
    event ItemRemoved(address indexed user, uint256 indexed itemId);

    function addItem(string calldata _name, uint256 _quantity, uint256 _price) public {
        require(_quantity > 0, "Quantity must be greater than zero");
        require(_price > 0, "Price must be greater than zero");

        uint256 newItemId = itemCount[msg.sender];
        inventories[msg.sender][newItemId] = Item(_name, _quantity, _price);
        itemCount[msg.sender]++;

        emit ItemAdded(msg.sender, newItemId, _name, _quantity, _price);
    }

    function updateItem(uint256 _itemId, string calldata _name, uint256 _quantity, uint256 _price) public {
        require(_itemId < itemCount[msg.sender], "Item does not exist");
        require(_quantity > 0, "Quantity must be greater than zero");
        require(_price > 0, "Price must be greater than zero");

        Item storage item = inventories[msg.sender][_itemId];
        (bool success,) = msg.sender.call(
            abi.encodeWithSignature("updateItem(uint256,string,uint256,uint256)", _itemId, _name, _quantity, _price)
        );
        require(success, "action failed");

        item.name = _name;
        item.quantity = _quantity;
        item.price = _price;

        emit ItemUpdated(msg.sender, _itemId, _name, _quantity, _price);
    }

    function removeItem(uint256 _itemId) public {
        require(_itemId < itemCount[msg.sender], "Item does not exist");

        delete inventories[msg.sender][_itemId];
        emit ItemRemoved(msg.sender, _itemId);
    }

    function getItem(address _user, uint256 _itemId) public view returns (string memory, uint256, uint256) {
        require(_itemId < itemCount[_user], "Item does not exist");

        Item storage item = inventories[_user][_itemId];
        return (item.name, item.quantity, item.price);
    }

    function getTotalItems(address _user) public view returns (uint256) {
        return itemCount[_user];
    }
}
