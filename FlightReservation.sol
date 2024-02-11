/**
 *Submitted for verification at Etherscan.io on 2023-02-07
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract FlightReservation {
    
    struct Listing{
        uint256 availability;
        uint256 price; //Price in ETH
    }

    address payable public manager;
    Listing public flights;
    mapping(uint=>mapping(address=>bool)) public reservations;
    uint public numReservations;
    uint public saleIteration;
    

    constructor() {
        manager = payable(msg.sender);
        flights.availability = 40;
        flights.price = 10000000000; // 10**-8 ETH
        saleIteration = 1;
        numReservations=0;
    }

    function bookFlight() payable external {
        require(
            msg.value >= flights.price,
            "Please pay full price"
        );
        require(
            flights.availability>0,
            "No more flights available"
        );
        uint refund = 0;
        if(reservations[saleIteration][tx.origin] == false){
            reservations[saleIteration][tx.origin] = true;
            numReservations+=1;
            flights.availability -= 1;
            refund = msg.value - flights.price;
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
        flights.price = newPrice;
        flights.availability = newAvailability;
        numReservations = 0;
        saleIteration+=1;
    }

    function blockSeats(uint numSeats) external{
        require(
            msg.sender == manager,
            "Only manager can reset state"
        );
        require(
            numSeats<=flights.availability,
            "Can't block more seats than available"
        );
        flights.availability -= numSeats;
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