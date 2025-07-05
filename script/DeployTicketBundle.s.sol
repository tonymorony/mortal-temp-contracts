// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "forge-std/console2.sol";
import {TicketBundle} from "../src/TicketBundle.sol";

contract DeployTicketBundle is Script {
    function run() external returns (TicketBundle) {
        address deployer = vm.envAddress("DEPLOYER");
        address payable treasury = payable(vm.envAddress("TREASURY"));

        vm.startBroadcast(deployer);
        TicketBundle ticketBundle = new TicketBundle(deployer, treasury);
        vm.stopBroadcast();

        console2.log("Deployed TicketBundle to:", address(ticketBundle));
        return ticketBundle;
    }
} 