// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.28;

import {CoprocessorAdapter} from
    "coprocessor-base-contract/CoprocessorAdapter.sol";

import {Message, Option, Usage} from "./Types.sol";
import {Callback} from "./Callback.sol";
import {Completer} from "./Completer.sol";

contract CoprocessorCompleter is CoprocessorAdapter, Completer {
    /// @notice Next completion ID
    uint256 nextCompletionId;

    /// @notice Amount of Ether is insufficient for completion
    error InsufficientPayment();

    constructor(address taskIssuerAddress, bytes32 machineHash)
        CoprocessorAdapter(taskIssuerAddress, machineHash)
    {}

    /// @inheritdoc Completer
    function calculateCompletionCost(
        string calldata,
        uint256,
        Message[] calldata,
        Option[] calldata
    ) public pure override returns (uint256) {
        return 0; // dummy value
    }

    /// @inheritdoc Completer
    function askCompletion(
        string calldata model,
        uint256 maxCompletionTokens,
        Message[] calldata messages,
        Option[] calldata options,
        Callback callback
    ) external payable override returns (uint256 completionId) {
        // Checks
        uint256 expectedFunds = calculateCompletionCost(
            model, maxCompletionTokens, messages, options
        );
        require(
            msg.value >= expectedFunds, InsufficientPayment()
        );

        // Effects
        completionId = nextCompletionId++;

        // Interactions
        callCoprocessor(
            abi.encode(
                completionId,
                model,
                maxCompletionTokens,
                messages,
                options,
                callback
            )
        );
    }

    function handleNotice(bytes32, bytes memory notice)
        internal
        override
    {
        uint256 completionId;
        Message[] memory messages;
        Usage memory usage;
        Callback callback;
        uint256 refund;

        (completionId, messages, usage, callback, refund) = abi.decode(notice, (uint256, Message[], Usage, Callback, uint256));

        callback.receiveResult{value: refund}(completionId, messages, usage);
    }
}
