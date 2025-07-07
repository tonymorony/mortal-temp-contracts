// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "openzeppelin-contracts/contracts/access/Ownable.sol";

contract TournamentTicket is Ownable {
    uint256 public ticketPrice;
    string public currentTournamentId;
    address payable public treasury;

    mapping(string => mapping(address => bool)) private tournamentTickets;
    mapping(string => address[]) private tournamentParticipants;
    mapping(string => bool) public startedTournaments;

    event TicketPurchased(address indexed user, string tournamentId);
    event TournamentStarted(string tournamentId);
    event TicketPriceChanged(uint256 newPrice);
    event TreasuryChanged(address newTreasury);
    event FundsWithdrawn(address to, uint256 amount);

    constructor(uint256 _ticketPrice, address payable _treasury) Ownable(msg.sender) {
        require(_treasury != address(0), "Invalid treasury");
        ticketPrice = _ticketPrice;
        treasury = _treasury;
    }

    function buyTicket() external payable {
        require(bytes(currentTournamentId).length > 0, "No active tournament");
        require(msg.value == ticketPrice, "Incorrect ETH amount");
        require(!tournamentTickets[currentTournamentId][msg.sender], "Ticket already purchased");

        tournamentTickets[currentTournamentId][msg.sender] = true;
        tournamentParticipants[currentTournamentId].push(msg.sender);

        emit TicketPurchased(msg.sender, currentTournamentId);
    }

    function hasTicket(address user) external view returns (bool) {
        return tournamentTickets[currentTournamentId][user];
    }

    function getCurrentTournamentId() external view returns (string memory) {
        return currentTournamentId;
    }

    function getParticipants() external view returns (address[] memory) {
        return tournamentParticipants[currentTournamentId];
    }

    function startNewTournament(string memory newTournamentId) external onlyOwner {
        require(bytes(newTournamentId).length > 0, "Tournament ID required");
        require(!startedTournaments[newTournamentId], "Tournament with this ID already exists");
        startedTournaments[newTournamentId] = true;
        currentTournamentId = newTournamentId;

        emit TournamentStarted(newTournamentId);
    }

    function setTicketPrice(uint256 newPrice) external onlyOwner {
        ticketPrice = newPrice;
        emit TicketPriceChanged(newPrice);
    }

    function setTreasury(address payable newTreasury) external onlyOwner {
        require(newTreasury != address(0), "Invalid treasury");
        treasury = newTreasury;
        emit TreasuryChanged(newTreasury);
    }

    function withdraw() external onlyOwner {
        uint256 amount = address(this).balance;
        require(amount > 0, "No funds to withdraw");
        (bool success,) = treasury.call{value: amount}("");
        require(success, "Withdraw failed");
        emit FundsWithdrawn(treasury, amount);
    }

    receive() external payable {
        revert("Use buyTicket()");
    }

    fallback() external payable {
        revert("Invalid call");
    }
}
