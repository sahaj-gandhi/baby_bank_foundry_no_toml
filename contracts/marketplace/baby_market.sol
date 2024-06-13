pragma solidity ^0.8.0;

contract BabyMarket {
    struct Baby {
        uint256 id;
        string name;
        uint256 price;
        address payable seller; // Change the type to address payable
        address buyer;
    }

    Baby[] public babies;
    uint256 public nextBabyId;

    event BabyListed(uint256 indexed id, string name, uint256 price, address indexed seller);
    event BabySold(uint256 indexed id, string name, uint256 price, address indexed seller, address indexed buyer);

    function listBaby(string memory _name, uint256 _price) public {
        babies.push(Baby(nextBabyId, _name, _price, payable(msg.sender), address(0))); // Convert msg.sender to payable
        emit BabyListed(nextBabyId, _name, _price, msg.sender);
        nextBabyId++;
    }

    function buyBaby(uint256 _id) public payable {
        require(_id < babies.length, "Invalid baby ID");
        Baby storage baby = babies[_id];
        require(baby.buyer == address(0), "Baby already sold");
        require(msg.value >= baby.price, "Insufficient funds");

        baby.buyer = msg.sender;
        baby.seller.transfer(msg.value);

        emit BabySold(baby.id, baby.name, baby.price, baby.seller, baby.buyer);
    }

    function getBabyCount() public view returns (uint256) {
        return babies.length;
    }
}