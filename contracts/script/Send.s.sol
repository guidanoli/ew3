// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.28;

import {Script} from "forge-std/Script.sol";

import {CoprocessorCompleter} from "../src/CoprocessorCompleter.sol";
import {Callback} from "../src/Callback.sol";
import {Role, Message, Option} from "../src/Types.sol";

struct RawMessage {
    string content;
    string role;
}

struct RawOption {
    string value;
    string key;
}

struct RawRequest {
    uint256 maxCompletionTokens;
    RawMessage[] messages;
    string model;
    RawOption[] options;
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

library LibRawOption {
    using LibRawOption for RawOption;

    function convert(RawOption memory rawOption) internal pure returns (Option memory) {
        return Option({key: rawOption.key, value: rawOption.value});
    }

    function convert(RawOption[] memory rawOptions) internal pure returns (Option[] memory messages) {
        messages = new Option[](rawOptions.length);
        for (uint256 i; i < rawOptions.length; ++i) {
            messages[i] = rawOptions[i].convert();
        }
    }
}

contract SendScript is Script {
    using LibRawMessage for RawMessage[];
    using LibRawOption for RawOption[];

    function send(
        CoprocessorCompleter coprocessorCompleter,
        Callback callback,
        string calldata requestJsonPath,
        string calldata completionIdFilePath
    ) external {
        string memory requestJson = vm.readFile(requestJsonPath);
        bytes memory encodedRawRequest = vm.parseJson(requestJson);
        RawRequest memory rawRequest = abi.decode(encodedRawRequest, (RawRequest));
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        uint256 completionId = coprocessorCompleter.askForCompletion(
            rawRequest.model,
            rawRequest.maxCompletionTokens,
            rawRequest.messages.convert(),
            rawRequest.options.convert(),
            callback
        );
        vm.stopBroadcast();
        vm.writeFile(completionIdFilePath, string.concat(vm.toString(completionId), "\n"));
    }
}
