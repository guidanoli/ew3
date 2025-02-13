// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.28;

import {Script} from "forge-std/Script.sol";

import {Completer} from "../src/Completer.sol";
import {Callback} from "../src/Callback.sol";
import {Role, Message, Option, Request} from "../src/Types.sol";

struct RawMessage {
    string content;
    string role;
}

struct RawRequest {
    uint256 maxCompletionTokens;
    RawMessage[] messages;
    string model;
    Option[] options;
}

library LibString {
    using LibString for string;

    error UnknownRoleString(string str);

    function toRole(string memory str) internal pure returns (Role) {
        if (str.eq("system")) {
            return Role.SYSTEM;
        } else if (str.eq("assistant")) {
            return Role.ASSISTANT;
        } else if (str.eq("user")) {
            return Role.USER;
        } else {
            revert UnknownRoleString(str);
        }
    }

    function eq(string memory str1, string memory str2) internal pure returns (bool) {
        return str1.hash() == str2.hash();
    }

    function hash(string memory str) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(str));
    }
}

library LibRawMessage {
    using LibString for string;
    using LibRawMessage for RawMessage;

    function convert(RawMessage memory rawMessage) internal pure returns (Message memory) {
        return Message({role: rawMessage.role.toRole(), content: rawMessage.content});
    }

    function convert(RawMessage[] memory rawMessages) internal pure returns (Message[] memory messages) {
        messages = new Message[](rawMessages.length);
        for (uint256 i; i < rawMessages.length; ++i) {
            messages[i] = rawMessages[i].convert();
        }
    }
}

library LibRawRequest {
    using LibRawMessage for RawMessage[];

    function convert(RawRequest memory rawRequest) internal pure returns (Request memory) {
        return Request({
            modelName: rawRequest.model,
            maxCompletionTokens: rawRequest.maxCompletionTokens,
            messages: rawRequest.messages.convert(),
            options: rawRequest.options
        });
    }
}

contract SendScript is Script {
    using LibRawRequest for RawRequest;

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
        bytes memory encodedRawRequest = vm.parseJson(requestJson);
        RawRequest memory rawRequest = abi.decode(encodedRawRequest, (RawRequest));
        return rawRequest.convert();
    }
}
