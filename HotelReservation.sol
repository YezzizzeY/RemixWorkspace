/**
 *Submitted for verification at Etherscan.io on 2023-02-07
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract HotelReservation {
    
    struct Listing{
        uint256 availability;
        uint256 price; //Price in ETH
    }

    address payable public manager;
    Listing public rooms;
    mapping(uint=>mapping(address=>bool)) public reservations;
    uint public numReservations;
    uint public saleIteration;
    

    constructor() {
        manager = payable(msg.sender);
        rooms.availability = 40;
        rooms.price = 10000000000; // 10**-8 ETH
        saleIteration = 1;
        numReservations=0;
    }

    function bookRoom() payable external {
        require(
            msg.value >= rooms.price,
            "Please pay full price"
        );
        require(
            rooms.availability>0,
            "No more rooms available"
        );
        uint refund = 0;
        if(reservations[saleIteration][tx.origin] == false){
            reservations[saleIteration][tx.origin] = true;
            numReservations+=1;
            rooms.availability -= 1;
            refund = msg.value - rooms.price;
        }
        else{
            refund = msg.value;
        }
        address payable refundAddress = payable(tx.origin);
        if (refund>0) {
            refundAddress.transfer(refund);
        }
    }

    function resetState(uint newPrice, uint newAvailability) external {
        require(
            msg.sender == manager,
            "Only manager can reset state"
        );
        rooms.price = newPrice;
        rooms.availability = newAvailability;
        numReservations = 0;
        saleIteration+=1;
    }

    function blockRooms(uint numRooms) external{
        require(
            msg.sender == manager,
            "Only manager can reset state"
        );
        require(
            numRooms<=rooms.availability,
            "Can't block more rooms than available"
        );
        rooms.availability -= numRooms;
    }

    function checkReservations(address CustomerAddress) external view returns(bool){
        return reservations[saleIteration][CustomerAddress];
    }

    function transferEarningsToManager() external{
       require(
            msg.sender == manager,
            "Only manager can reset state"
        );
        manager.transfer(address(this).balance);
    }

}