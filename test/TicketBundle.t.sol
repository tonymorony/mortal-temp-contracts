// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import {TicketBundle} from "../src/TicketBundle.sol";

contract TicketBundleTest is Test {
    TicketBundle public ticketBundle;
    address public owner;
    address payable public treasury;
    address public user;

    uint256 packageId = 1;
    uint256 ticketCount = 10;
    uint256 price = 0.1 ether;

    function setUp() public {
        owner = address(this);
        treasury = payable(address(0xBEEF));
        user = address(0x1234);

        vm.deal(user, 1 ether);

        ticketBundle = new TicketBundle(owner, treasury);
    }

    function test_GetAllPackageIds() public {
        vm.prank(owner);
        ticketBundle.setPackage(1, 10, 0.1 ether, true);
        vm.prank(owner);
        ticketBundle.setPackage(2, 25, 0.2 ether, true);

        uint256[] memory ids = ticketBundle.getAllPackageIds();
        assertEq(ids.length, 2, "Should return two package IDs");
        assertEq(ids[0], 1, "First ID should be 1");
        assertEq(ids[1], 2, "Second ID should be 2");
    }

    function test_RemovePackage() public {
        // Create two packages
        vm.prank(owner);
        ticketBundle.setPackage(1, 10, 0.1 ether, true);
        vm.prank(owner);
        ticketBundle.setPackage(2, 25, 0.2 ether, true);

        // Remove package 1
        vm.prank(owner);
        ticketBundle.removePackage(1);

        // Check that package 1 is inactive
        (, , bool isActive) = ticketBundle.packages(1);
        assertFalse(isActive, "Package 1 should be inactive");

        // Check that the ID list is correct
        uint256[] memory ids = ticketBundle.getAllPackageIds();
        assertEq(ids.length, 1, "Should only be one package ID left");
        assertEq(ids[0], 2, "Remaining package ID should be 2");

        // Try to buy the removed package
        vm.prank(user);
        vm.expectRevert("Package is not active");
        ticketBundle.buyPackage{value: 0.1 ether}(1);
    }

    function test_GetAllPackages() public {
        // Create two packages
        vm.prank(owner);
        ticketBundle.setPackage(1, 10, 0.1 ether, true);
        vm.prank(owner);
        ticketBundle.setPackage(2, 25, 0.2 ether, true);

        TicketBundle.Package[] memory allPkgs = ticketBundle.getAllPackages();

        assertEq(allPkgs.length, 2, "Should return two packages");

        // Check package 1
        assertEq(allPkgs[0].ticketCount, 10);
        assertEq(allPkgs[0].priceInWei, 0.1 ether);
        assertTrue(allPkgs[0].isActive);

        // Check package 2
        assertEq(allPkgs[1].ticketCount, 25);
        assertEq(allPkgs[1].priceInWei, 0.2 ether);
        assertTrue(allPkgs[1].isActive);
    }

    function test_OwnerCanSetPackage() public {
        vm.prank(owner);
        ticketBundle.setPackage(packageId, ticketCount, price, true);

        (uint256 _ticketCount, uint256 _price, bool _isActive) = ticketBundle.packages(packageId);

        assertEq(_ticketCount, ticketCount, "Ticket count should match");
        assertEq(_price, price, "Price should match");
        assertTrue(_isActive, "Package should be active");

        uint256[] memory ids = ticketBundle.getAllPackageIds();
        assertEq(ids.length, 1, "Should have one package ID");
        assertEq(ids[0], packageId, "Package ID should match");
    }

    function test_BuyPackage() public {
        vm.prank(owner);
        ticketBundle.setPackage(packageId, ticketCount, price, true);

        vm.expectEmit(true, true, false, true);
        emit TicketBundle.PackagePurchased(user, packageId, 1, ticketCount);

        vm.prank(user);
        ticketBundle.buyPackage{value: price}(packageId);

        assertEq(ticketBundle.getPurchaseCount(user, packageId), 1, "Purchase count should be 1");
        assertEq(treasury.balance, price, "Treasury should receive the ETH");
    }

    function test_RevertWhen_BuyInactivePackage() public {
        vm.prank(owner);
        ticketBundle.setPackage(packageId, ticketCount, price, false); // Package is inactive

        vm.prank(user);
        vm.expectRevert("Package is not active");
        ticketBundle.buyPackage{value: price}(packageId);
    }

    function test_RevertWhen_IncorrectValueSent() public {
        vm.prank(owner);
        ticketBundle.setPackage(packageId, ticketCount, price, true);

        vm.prank(user);
        vm.expectRevert("Incorrect ETH value sent");
        ticketBundle.buyPackage{value: price - 0.01 ether}(packageId);
    }

    function test_RevertWhen_NonOwnerSetsPackage() public {
        vm.prank(user);
        vm.expectRevert(abi.encodeWithSignature("OwnableUnauthorizedAccount(address)", user));
        ticketBundle.setPackage(packageId, ticketCount, price, true);
    }

    function test_MultiplePurchases() public {
        vm.prank(owner);
        ticketBundle.setPackage(packageId, ticketCount, price, true);

        // First purchase
        vm.prank(user);
        ticketBundle.buyPackage{value: price}(packageId);
        assertEq(ticketBundle.getPurchaseCount(user, packageId), 1, "First purchase count should be 1");
        assertEq(treasury.balance, price, "Treasury balance after first purchase");

        // Second purchase
        vm.prank(user);
        ticketBundle.buyPackage{value: price}(packageId);
        assertEq(ticketBundle.getPurchaseCount(user, packageId), 2, "Second purchase count should be 2");
        assertEq(treasury.balance, price * 2, "Treasury balance after second purchase");
    }
} 