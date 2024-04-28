// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract Dappazon {

    address public owner;
    struct Item{ //user defined datatype 
        uint256 id;
        string name;
        string category;
        string  image;
        uint256 cost;
        uint256 rating;
        uint256 stock;
    }

    struct Order { 
        uint256 time ; 
        Item item;
    }
    
    mapping (uint256 => Item) public items ;
    mapping (address => uint256) public orderCount;
    mapping (address => mapping(uint256 => Order )) public orders; //Nested Mapping 


    event Buy (address buyer , uint256 orderId ,uint256 itemId);
    event List(string name, uint256 cost, uint256 quantity);

    modifier onlyOwner(){ // this onlyOwner function is used below ; it says do the function body only if its called by the owner
        require(msg.sender == owner);
        _; // this line represents the function body 
    }

    constructor (){  //constructor function occurs only once when its in the blockchain 
        owner = msg.sender;
    } 

    
    //List Products 

    function list(
        uint256 _id,
        string memory _name,
        string memory _category,
        string memory _image,
        uint256 _cost,
        uint256 _rating ,
        uint256 _stock
    )public onlyOwner{
        require(msg.sender == owner);
        // Create Item struct 

        Item memory item = Item(
            _id,
            _name,
            _category,
            _image,
            _cost,
            _rating,
            _stock
        );

        //Save item struct to Blockchain
        items[_id] = item;

        //Emit an Event

        emit List (_name,_cost,_stock);

        
    }
    //Buy products




    function buy ( uint256 _id) public payable { 
        //Receive crypto =>  this part is done in testing 

        //Fetch Items from blockchain to purchase 
        Item memory item = items[_id];

        //Require enough ether to buy item 
        require(msg.value >= item.cost);

        //Require item is in stock or not 
        require(item.stock  > 0);

        //Create an Order
        Order memory order = Order (block.timestamp,item);

        //Save order to chain
        orderCount[msg.sender]++; 
        orders[msg.sender][orderCount[msg.sender]] = order;


        //Subtract Stock
        items[_id].stock = item.stock - 1;

        //Emit Event
        emit Buy (msg.sender,orderCount[msg.sender],item.id);
    }

    //Withdraw funds

    function withdraw() public onlyOwner{
        (bool success , ) = owner.call{value: address(this).balance}(""); 
        require(success);
    }

}
