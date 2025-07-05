// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "forge-std/console2.sol";
import "../src/TournamentTicket.sol";

contract DeployScript is Script {
    function run() external {
        address payable treasury = payable(vm.envAddress("TREASURY"));
        uint256 price = 0.01 ether;

        vm.startBroadcast();
        TournamentTicket ticket = new TournamentTicket(price, treasury);
        vm.stopBroadcast();

        console2.log("Deployed to:", address(ticket));
    }
}
