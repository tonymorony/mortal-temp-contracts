// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Ownable} from "lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "lib/openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";

/**
 * @title TicketBundle
 * @author anton.lyaskov
 * @notice A contract for purchasing bundles of tickets for a tournament.
 * Admins can define packages with a specific number of tickets and a price in ETH.
 * Users can buy these packages, and the purchase information is stored on-chain
 * for backend validation.
 */
contract TicketBundle is Ownable, ReentrancyGuard {
    struct Package {
        uint256 ticketCount;
        uint256 priceInWei;
        bool isActive;
    }

    mapping(uint256 => Package) public packages;
    mapping(address => mapping(uint256 => uint256)) public purchases; // user => packageId => count

    uint256[] public allPackageIds;
    address payable public treasury;

    event PackageSet(uint256 indexed packageId, uint256 ticketCount, uint256 priceInWei, bool isActive);
    event PackagePurchased(address indexed user, uint256 indexed packageId, uint256 purchaseCount, uint256 ticketCount);
    event PackageRemoved(uint256 indexed packageId);

    constructor(address initialOwner, address payable _treasury) Ownable(initialOwner) {
        require(_treasury != address(0), "Treasury address cannot be zero");
        treasury = _treasury;
    }

    function setTreasury(address payable _treasury) external onlyOwner {
        require(_treasury != address(0), "Treasury address cannot be zero");
        treasury = _treasury;
    }

    function setPackage(uint256 packageId, uint256 ticketCount, uint256 priceInWei, bool isActive) external onlyOwner {
        if (packages[packageId].priceInWei == 0) {
            allPackageIds.push(packageId);
        }
        packages[packageId] = Package(ticketCount, priceInWei, isActive);
        emit PackageSet(packageId, ticketCount, priceInWei, isActive);
    }

    function removePackage(uint256 packageId) external onlyOwner {
        require(packages[packageId].priceInWei > 0, "Package does not exist");

        packages[packageId].isActive = false;

        for (uint i = 0; i < allPackageIds.length; i++) {
            if (allPackageIds[i] == packageId) {
                allPackageIds[i] = allPackageIds[allPackageIds.length - 1];
                allPackageIds.pop();
                break;
            }
        }

        emit PackageRemoved(packageId);
    }

    function buyPackage(uint256 packageId) external payable nonReentrant {
        Package storage currentPackage = packages[packageId];
        require(currentPackage.isActive, "Package is not active");
        require(currentPackage.priceInWei > 0, "Package price must be greater than 0");
        require(msg.value == currentPackage.priceInWei, "Incorrect ETH value sent");

        purchases[msg.sender][packageId]++;
        
        emit PackagePurchased(msg.sender, packageId, purchases[msg.sender][packageId], currentPackage.ticketCount);

        (bool success, ) = treasury.call{value: msg.value}("");
        require(success, "Failed to send ETH to treasury");
    }

    function getAllPackageIds() external view returns (uint256[] memory) {
        return allPackageIds;
    }

    function getAllPackages() external view returns (Package[] memory) {
        Package[] memory allPackages = new Package[](allPackageIds.length);
        for (uint i = 0; i < allPackageIds.length; i++) {
            allPackages[i] = packages[allPackageIds[i]];
        }
        return allPackages;
    }

    function getPurchaseCount(address user, uint256 packageId) external view returns (uint256) {
        return purchases[user][packageId];
    }
} 