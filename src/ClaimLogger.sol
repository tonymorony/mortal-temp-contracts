// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title ClaimLogger
 * @notice This contract is used exclusively to prove an action was taken.
 * A user calls the claim() function to generate an event, which a backend can
 * verify for spam protection when issuing off-chain tickets.
 */
contract ClaimLogger {
    event Claimed(address indexed user, uint256 timestamp);

    /**
     * @notice A user calls this function to prove they have taken an action.
     * It returns nothing and only emits an event.
     */
    function claim() external {
        emit Claimed(msg.sender, block.timestamp);
    }
} 