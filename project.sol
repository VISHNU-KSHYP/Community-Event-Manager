// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CommunityEventManager {
    
    struct Event {
        string name;
        string description;
        uint256 date;
        address payable manager;
        uint256 reward;
        bool isCompleted;
    }

    Event[] public events;
    mapping(address => uint256) public managerEarnings;

    event EventCreated(
        uint256 eventId,
        string name,
        string description,
        uint256 date,
        address manager,
        uint256 reward
    );

    event EventCompleted(
        uint256 eventId,
        address manager,
        uint256 reward
    );

    // Function to create a new community event
    function createEvent(
        string memory name,
        string memory description,
        uint256 date,
        uint256 reward
    ) public payable {
        require(msg.value == reward, "Insufficient reward amount provided.");
        require(date > block.timestamp, "Event date must be in the future.");

        events.push(Event({
            name: name,
            description: description,
            date: date,
            manager: payable(msg.sender),
            reward: reward,
            isCompleted: false
        }));

        emit EventCreated(events.length - 1, name, description, date, msg.sender, reward);
    }

    // Function to mark an event as completed
    function completeEvent(uint256 eventId) public {
        Event storage eventDetails = events[eventId];
        require(eventDetails.manager == msg.sender, "Only the event manager can mark this event as completed.");
        require(eventDetails.date <= block.timestamp, "Event date has not yet arrived.");
        require(!eventDetails.isCompleted, "Event is already completed.");

        eventDetails.isCompleted = true;
        managerEarnings[msg.sender] += eventDetails.reward;

        emit EventCompleted(eventId, msg.sender, eventDetails.reward);
    }

    // Function to withdraw earnings
    function withdrawEarnings() public {
        uint256 amount = managerEarnings[msg.sender];
        require(amount > 0, "No earnings to withdraw.");

        managerEarnings[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
    }

    // Get all events
    function getAllEvents() public view returns (Event[] memory) {
        return events;
    }
}