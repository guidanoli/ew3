// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.28;

import {Script} from "forge-std/Script.sol";

import {CoprocessorCompleter} from "../src/CoprocessorCompleter.sol";

contract DeployScript is Script {
    function deploy(address taskIssuerAddress, bytes32 machineHash) external {
        bytes32 salt;
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        CoprocessorCompleter coprocessorCompleter = new CoprocessorCompleter{salt: salt}(taskIssuerAddress, machineHash);
        vm.stopBroadcast();
        string memory objectKey = "deployments";
        string memory json = vm.serializeAddress(objectKey, "CoprocessorCompleter", address(coprocessorCompleter));
        vm.writeJson(json, string.concat(vm.projectRoot(), "/deployments.json"));
    }
}
