// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "forge-std/console2.sol";
import "../src/ClaimLogger.sol";

contract DeployClaimLogger is Script {
    function run() external {
        vm.startBroadcast();
        ClaimLogger logger = new ClaimLogger();
        vm.stopBroadcast();

        console2.log("ClaimLogger deployed to:", address(logger));
    }
} 