// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.28;

import {Script} from "forge-std/Script.sol";

import {Completer} from "../src/Completer.sol";
import {Callback} from "../src/Callback.sol";
import {Message, Option, Request} from "../src/Types.sol";

contract SendScript is Script {
    function send(
        Completer completer,
        Callback callback,
        string calldata requestJsonPath,
        string calldata completionIdFilePath
    ) external {
        Request memory request = _loadRequestFromJsonFile(requestJsonPath);
        uint256 cost = completer.getCompletionRequestCost(request);
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        uint256 completionId = completer.requestCompletion{value: cost}(request, callback);
        vm.stopBroadcast();
        vm.writeFile(completionIdFilePath, string.concat(vm.toString(completionId), "\n"));
    }

    function _loadRequestFromJsonFile(string calldata requestJsonPath) internal view returns (Request memory) {
        string memory requestJson = vm.readFile(requestJsonPath);
        bytes memory encodedRequest = vm.parseJson(requestJson);
        return abi.decode(encodedRequest, (Request));
    }
}
