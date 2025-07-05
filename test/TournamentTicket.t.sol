// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/TournamentTicket.sol";

contract TournamentTicketTest is Test {
    TournamentTicket public ticket;
    address payable treasury = payable(address(0xBEEF));
    address user = address(0x1234);
    address otherUser = address(0x4567);

    function setUp() public {
        ticket = new TournamentTicket(0.01 ether, treasury);
        vm.deal(user, 1 ether);
        vm.deal(otherUser, 1 ether);
    }

    function testBuyTicket() public {
        // Ожидаем событие о покупке билета
        vm.expectEmit(true, true, true, true);
        emit TournamentTicket.TicketPurchased(user, ticket.getCurrentTournamentId());

        // Пользователь покупает билет
        vm.prank(user);
        ticket.buyTicket{value: 0.01 ether}();

        // Проверяем, что у пользователя теперь есть билет
        assertTrue(ticket.hasTicket(user));
        // Проверяем, что баланс контракта увеличился на цену билета
        assertEq(address(ticket).balance, 0.01 ether);
        // Проверяем, что количество участников стало 1
        assertEq(ticket.getParticipants().length, 1);
    }

    function test_RevertWhen_DoubleBuy() public {
        vm.prank(user);
        ticket.buyTicket{value: 0.01 ether}();

        vm.prank(user);
        vm.expectRevert("Ticket already purchased");
        ticket.buyTicket{value: 0.01 ether}();
    }

    function test_RevertWhen_IncorrectPrice() public {
        vm.prank(user);
        vm.expectRevert("Incorrect ETH amount");
        ticket.buyTicket{value: 0.005 ether}();
    }

    function test_RevertWhen_WithdrawByNotOwner() public {
        vm.prank(user);
        vm.expectRevert(abi.encodeWithSignature("OwnableUnauthorizedAccount(address)", user));
        ticket.withdraw();
    }

    function testWithdraw() public {
        vm.prank(user);
        ticket.buyTicket{value: 0.01 ether}();

        uint256 before = treasury.balance;

        vm.prank(ticket.owner());
        ticket.withdraw();

        uint256 afterBal = treasury.balance;
        assertEq(afterBal - before, 0.01 ether);
    }

    function testStartNewTournamentClearsTickets() public {
        vm.prank(user);
        ticket.buyTicket{value: 0.01 ether}();

        vm.prank(ticket.owner());
        ticket.startNewTournament("season-2");

        assertFalse(ticket.hasTicket(user));
        assertEq(ticket.getCurrentTournamentId(), "season-2");
    }

    function testSetTicketPrice() public {
        vm.prank(ticket.owner());
        ticket.setTicketPrice(0.02 ether);
        assertEq(ticket.ticketPrice(), 0.02 ether);
    }

    function testSetTreasury() public {
        vm.prank(ticket.owner());
        ticket.setTreasury(payable(otherUser));
        assertEq(ticket.treasury(), payable(otherUser));
    }

    function test_RevertWhen_NonOwnerSetTreasury() public {
        vm.prank(user);
        vm.expectRevert(abi.encodeWithSignature("OwnableUnauthorizedAccount(address)", user));
        ticket.setTreasury(payable(otherUser));
    }

    function test_RevertWhen_StartTournamentWithEmptyId() public {
        vm.prank(ticket.owner());
        vm.expectRevert("Tournament ID required");
        ticket.startNewTournament("");
    }

    function test_RevertWhen_WithdrawEmpty() public {
        vm.prank(ticket.owner());
        vm.expectRevert("No funds to withdraw");
        ticket.withdraw();
    }
}
