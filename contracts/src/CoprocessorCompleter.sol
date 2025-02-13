// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.28;

import {CoprocessorAdapter} from "coprocessor-base-contract/CoprocessorAdapter.sol";

import {Request, Message, Option, Usage} from "./Types.sol";
import {Callback} from "./Callback.sol";
import {Completer} from "./Completer.sol";

contract CoprocessorCompleter is CoprocessorAdapter, Completer {
    uint256 nextCompletionId;

    constructor(address taskIssuerAddress, bytes32 machineHash) CoprocessorAdapter(taskIssuerAddress, machineHash) {}

    /// @inheritdoc Completer
    function getCompletionRequestCost(Request calldata) public pure override returns (uint256) {
        return 0;
    }

    /// @inheritdoc Completer
    function requestCompletion(Request calldata request, Callback callback)
        external
        payable
        override
        returns (uint256 completionId)
    {
        uint256 cost = getCompletionRequestCost(request);
        require(cost <= msg.value, InsufficientPayment(cost, msg.value));
        completionId = nextCompletionId++;
        callCoprocessor(
            abi.encode(
                completionId,
                request.modelName,
                request.maxCompletionTokens,
                request.messages,
                request.options,
                callback
            )
        );
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
