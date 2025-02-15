// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.28;

import {Vm} from "forge-std/Vm.sol";
import {console} from "forge-std/console.sol";

import {BaseScript} from "./Base.s.sol";
import {Callback} from "../src/Callback.sol";
import {Message, Usage} from "../src/Types.sol";

struct Result {
    address requester;
    uint256 refund;
    Message[] messages;
    Usage usage;
}

contract GetResultScript is BaseScript {
    string constant USAGE_TYPEDESC = "Usage(uint256 promptTokens,uint256 completionTokens)";
    string constant MESSAGE_TYPEDESC = "Message(string content, string role)";
    string constant RESULT_TYPEDESC = "Result(address requester, uint256 refund, Message[] messages, Usage usage)";

    function getResult(Callback callback, uint256 completionId, address caller, string calldata resultJsonPath)
        external
    {
        uint256 fromBlock = callback.getDeploymentBlockNumber();
        uint256 toBlock = block.number;
        address target = address(callback);
        bytes32[] memory topics = new bytes32[](3);
        topics[0] = Callback.ResultReceived.selector;
        topics[1] = bytes32(completionId);
        topics[2] = bytes32(uint256(uint160(caller)));
        Vm.EthGetLogs[] memory logs = vm.eth_getLogs(fromBlock, toBlock, target, topics);
        if (logs.length >= 1) {
            Vm.EthGetLogs memory log = logs[0];
            string memory typedesc = string.concat(RESULT_TYPEDESC, MESSAGE_TYPEDESC, USAGE_TYPEDESC);
            bytes memory encodedResult = abi.encodePacked(uint256(0x20), log.data);
            string memory json = vm.serializeJsonType(typedesc, encodedResult);
            vm.writeFile(resultJsonPath, string.concat(json, "\n"));
        }
    }
}
