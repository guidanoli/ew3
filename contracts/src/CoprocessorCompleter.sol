// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.28;

import {CoprocessorAdapter} from "coprocessor-base-contract/CoprocessorAdapter.sol";

import {Message, Option, Usage} from "./Types.sol";
import {Callback} from "./Callback.sol";
import {Completer} from "./Completer.sol";

contract CoprocessorCompleter is CoprocessorAdapter, Completer {
    uint256 nextCompletionId;

    constructor(address taskIssuerAddress, bytes32 machineHash) CoprocessorAdapter(taskIssuerAddress, machineHash) {}

    /// @inheritdoc Completer
    function getCompletionRequestCost(string calldata, uint256, Message[] calldata)
        public
        pure
        override
        returns (uint256)
    {
        return 0;
    }

    /// @inheritdoc Completer
    function requestCompletion(
        string calldata modelName,
        uint256 maxCompletionTokens,
        Message[] calldata messages,
        Option[] calldata options,
        Callback callback
    ) external override returns (uint256 completionId) {
        completionId = nextCompletionId++;
        callCoprocessor(abi.encode(completionId, modelName, maxCompletionTokens, messages, options, callback));
    }

    /// @inheritdoc CoprocessorAdapter
    function handleNotice(bytes32, bytes memory notice) internal override {
        uint256 completionId;
        Callback callback;
        Message[] memory messages;
        Usage memory usage;
        (completionId, callback, messages, usage) = abi.decode(notice, (uint256, Callback, Message[], Usage));
        callback.receiveResult(completionId, messages, usage);
    }
}
