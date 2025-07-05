// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/ClaimLogger.sol";

contract ClaimLoggerTest is Test {
    ClaimLogger public logger;
    address user = address(0x1234);

    function setUp() public {
        logger = new ClaimLogger();
    }

    function test_ClaimEmitsEvent() public {
        // Ожидаем событие Claimed с указанием адреса пользователя.
        // Мы не можем точно проверить block.timestamp, поэтому для него ставим true.
        vm.expectEmit(true, false, false, true);
        emit ClaimLogger.Claimed(user, block.timestamp);

        // Пользователь вызывает функцию claim
        vm.prank(user);
        logger.claim();
    }
} 