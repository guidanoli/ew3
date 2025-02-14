// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.28;

import {Script} from "forge-std/Script.sol";

import {ModelCostTable} from "../src/Types.sol";
import {CoprocessorCompleter} from "../src/CoprocessorCompleter.sol";
import {SimpleCallback} from "../src/SimpleCallback.sol";

contract DeployScript is Script {
    bytes32 constant salt = bytes32(0);

    function deploy(address taskIssuer, bytes32 machineHash, string calldata modelsJsonPath, uint256 costMultiplier)
        external
    {
        _deployCompleter(taskIssuer, machineHash, modelsJsonPath, costMultiplier);
        _deployCallback();
    }

    function _deployCompleter(
        address taskIssuer,
        bytes32 machineHash,
        string calldata modelsJsonPath,
        uint256 costMultiplier
    ) internal {
        address completerAddress;
        CoprocessorCompleter.Model[] memory models;
        models = _multiplyCosts(_loadModelsFromJsonFile(modelsJsonPath), costMultiplier);
        // Compute target address
        {
            bytes memory args = abi.encode(taskIssuer, machineHash, models);
            bytes memory initCode = abi.encodePacked(type(CoprocessorCompleter).creationCode, args);
            bytes32 initCodeHash = keccak256(initCode);
            completerAddress = vm.computeCreate2Address(salt, initCodeHash);
        }
        // Write target address to file
        {
            string memory dir = string.concat(vm.projectRoot(), "/deployments");
            if (!vm.isDir(dir)) vm.createDir(dir, true);
            string memory path = string.concat(dir, "/CoprocessorCompleter");
            string memory data = string.concat(vm.toString(completerAddress), "\n");
            vm.writeFile(path, data);
        }
        // Check if target address has code already
        {
            uint256 size;
            assembly {
                size := extcodesize(completerAddress)
            }
            if (size != 0) return;
        }
        // Deploy contract if target address has no code yet
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        CoprocessorCompleter completer;
        completer = new CoprocessorCompleter{salt: salt}(taskIssuer, machineHash, models);
        require(address(completer) == completerAddress, "address mismatch");
        vm.stopBroadcast();
    }

    function _loadModelsFromJsonFile(string calldata modelsJsonPath)
        internal
        view
        returns (CoprocessorCompleter.Model[] memory)
    {
        string memory modelsJson = vm.readFile(modelsJsonPath);
        bytes memory encodedModels = vm.parseJson(modelsJson);
        return abi.decode(encodedModels, (CoprocessorCompleter.Model[]));
    }

    function _multiplyCosts(CoprocessorCompleter.Model[] memory models, uint256 multipler)
        internal
        pure
        returns (CoprocessorCompleter.Model[] memory newModels)
    {
        newModels = new CoprocessorCompleter.Model[](models.length);
        for (uint256 i; i < models.length; ++i) {
            newModels[i] = _multiplyCosts(models[i], multipler);
        }
    }

    function _multiplyCosts(CoprocessorCompleter.Model memory model, uint256 multipler)
        internal
        pure
        returns (CoprocessorCompleter.Model memory)
    {
        return CoprocessorCompleter.Model({name: model.name, costs: _multiplyCosts(model.costs, multipler)});
    }

    function _multiplyCosts(ModelCostTable memory costs, uint256 multipler)
        internal
        pure
        returns (ModelCostTable memory)
    {
        return ModelCostTable({
            perCompletionToken: costs.perCompletionToken * multipler,
            perPromptToken: costs.perPromptToken * multipler
        });
    }

    function _deployCallback() internal {
        address simpleCallbackAddress;
        // Compute target address
        {
            bytes memory args = abi.encode();
            bytes memory initCode = abi.encodePacked(type(SimpleCallback).creationCode, args);
            bytes32 initCodeHash = keccak256(initCode);
            simpleCallbackAddress = vm.computeCreate2Address(salt, initCodeHash);
        }
        // Write target address to file
        {
            string memory dir = string.concat(vm.projectRoot(), "/deployments");
            if (!vm.isDir(dir)) vm.createDir(dir, true);
            string memory path = string.concat(dir, "/SimpleCallback");
            string memory data = string.concat(vm.toString(simpleCallbackAddress), "\n");
            vm.writeFile(path, data);
        }
        // Check if target address has code already
        {
            uint256 size;
            assembly {
                size := extcodesize(simpleCallbackAddress)
            }
            if (size != 0) return;
        }
        // Deploy contract if target address has no code yet
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        SimpleCallback simpleCallback = new SimpleCallback{salt: salt}();
        require(address(simpleCallback) == simpleCallbackAddress, "address mismatch");
        vm.stopBroadcast();
    }
}
