// SPDX-License-Identifier: Unlicensed

pragma solidity >=0.5.0 <0.9.0;

contract EventContract{

    address eventOwner;
    address ticketBuyer;

    struct Event{
        address organizer;
        string name;
        uint256 date;
        uint256 price;
        uint256 ticketCount;
        uint256 ticketRemain;
    }

    mapping(uint=>Event) public events;
    mapping(address=>mapping(uint=>uint)) public tickets;
    uint public nextId;

    function createEvent(string memory name, uint256 date, uint256 price, uint256 ticketCount) external{
        require(date>block.timestamp,"You can ogranize event for future date");
        require(ticketCount>0,"You can organize event only if have atleast 1 ticket");
    
        events[nextId] = Event(msg.sender, name, date, price, ticketCount,ticketCount);
        nextId++;
        eventOwner = msg.sender;
    }
    function buyTicket(uint id,uint quantity) external payable {
        ticketBuyer = msg.sender;
        require(ticketBuyer!=ticketBuyer,"Event creator cannot buy the ticket");  //to check if the event creator is not one buying tickets
        require(events[id].date>block.timestamp,"The event is already over"); //to check the event date is after the current date
        require(events[id].date!=0, "The event doesn't exist"); // to check if the event exits in the event date or not
        Event storage _event = events[id];
        require(msg.value==(_event.price*quantity),"Ether is not enough"); //to check the buyer has paid the buying amount/ether for the tickets
        require(_event.ticketRemain>=quantity,"Not Enough tickets"); // to check if there are enough tickets available to be sold
        _event.ticketRemain-=quantity;   // since the tickets have been sold the remaining quantity is reduced
        tickets[ticketBuyer][id]+=quantity; //since the tickets is bought by the buyer, the tickets for that evnt shall be added to his address
        
    }

    function ticketTransfer(uint eventId, uint quantity, address transferTo) external{
        require((transferTo != ticketBuyer && transferTo != eventOwner),"Cannot transfer tickets to same address or the event creator");
        require(events[eventId].date>block.timestamp,"The event is already over"); //to check the event date is after the current date
        require(events[eventId].date!=0, "The event doesn't exist"); // to check if the event exits in the event date or not
        require(tickets[ticketBuyer][eventId]>=quantity,"You do not have enough tickets to transfer");// check to see that the no of tickets to be transferred is available with the ticket buyer or not 

        tickets[ticketBuyer][eventId]-=quantity; //substract the no of tickets transferred from the buyer account
        tickets[transferTo][eventId]+=quantity; //add the total no of transferred tickets to the receipient account
    
    
    }


}
