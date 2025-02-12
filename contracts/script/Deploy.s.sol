// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.28;

import {Script} from "forge-std/Script.sol";

import {CoprocessorCompleter} from "../src/CoprocessorCompleter.sol";

contract DeployScript is Script {
    bytes32 constant salt = bytes32(0);

    function deploy(address taskIssuerAddress, bytes32 machineHash) external {
        address coprocessorCompleterAddress;
        // Compute target address
        {
            bytes memory args = abi.encode(taskIssuerAddress, machineHash);
            bytes memory initCode = abi.encodePacked(type(CoprocessorCompleter).creationCode, args);
            bytes32 initCodeHash = keccak256(initCode);
            coprocessorCompleterAddress = vm.computeCreate2Address(salt, initCodeHash);
        }
        // Write target address to file
        {
            string memory dir = string.concat(vm.projectRoot(), "/deployments");
            if (!vm.isDir(dir)) vm.createDir(dir, true);
            string memory path = string.concat(dir, "/CoprocessorCompleter");
            string memory data = string.concat(vm.toString(coprocessorCompleterAddress), "\n");
            vm.writeFile(path, data);
        }
        // Check if target address has code already
        {
            uint256 size;
            assembly {
                size := extcodesize(coprocessorCompleterAddress)
            }
            if (size != 0) return;
        }
        // Deploy contract if target address has no code yet
        {
            vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
            CoprocessorCompleter coprocessorCompleter = new CoprocessorCompleter{salt: salt}(taskIssuerAddress, machineHash);
            require(address(coprocessorCompleter) == coprocessorCompleterAddress, "address mismatch");
            vm.stopBroadcast();
        }
    }
}
