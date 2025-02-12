// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.28;

import {Script} from "forge-std/Script.sol";

import {CoprocessorCompleter} from "../src/CoprocessorCompleter.sol";

contract DeployScript is Script {
    function deploy(address taskIssuerAddress, bytes32 machineHash) external {
        bytes32 salt;
        bytes memory args = abi.encode(taskIssuerAddress, machineHash);
        bytes memory initCode = abi.encodePacked(type(CoprocessorCompleter).creationCode, args);
        bytes32 initCodeHash = keccak256(initCode);
        address coprocessorCompleterAddress = vm.computeCreate2Address(salt, initCodeHash);
        string memory objectKey = "deployments";
        string memory json = vm.serializeAddress(objectKey, "CoprocessorCompleter", coprocessorCompleterAddress);
        vm.writeJson(json, string.concat(vm.projectRoot(), "/deployments.json"));
        uint256 size;
        assembly {
            size := extcodesize(coprocessorCompleterAddress)
        }
        if (size != 0) return;
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        CoprocessorCompleter coprocessorCompleter = new CoprocessorCompleter{salt: salt}(taskIssuerAddress, machineHash);
        require(address(coprocessorCompleter) == coprocessorCompleterAddress, "address mismatch");
        vm.stopBroadcast();
    }
}
