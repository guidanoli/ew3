// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.28;

import {CoprocessorAdapter} from "coprocessor-base-contract/CoprocessorAdapter.sol";

import {Message, Option, Usage} from "./Types.sol";
import {Callback} from "./Callback.sol";
import {Completer} from "./Completer.sol";

contract CoprocessorCompleter is CoprocessorAdapter, Completer {
    /// @notice Locked amount recipient
    address immutable _lockedAmountRecipient;

    /// @notice Locked amount (safe to be withdrawn)
    uint256 _lockedAmount;

    /// @notice Completion data
    struct Completion {
        uint256 paidAmount;
        uint256 promptLength;
        Callback callback;
        bool done;
    }

    /// @notice Completions (index = id)
    Completion[] _completions;

    /// @notice Amount of Ether is insufficient for completion
    error InsufficientPayment();

    /// @notice Could not withdraw Ether
    error FailedWithdrawal();

    /// @notice Completion was already done
    error CompletionAlreadyDone();

    constructor(address taskIssuerAddress, bytes32 machineHash, address lockedAmountRecipient)
        CoprocessorAdapter(taskIssuerAddress, machineHash)
    {
        _lockedAmountRecipient = lockedAmountRecipient;
    }

    /// @inheritdoc Completer
    function calculateCompletionCost(string calldata model, uint256 maxCompletionTokens, Message[] calldata messages)
        public
        pure
        override
        returns (uint256)
    {
        return _calculateCompletionCostCalldata(model, maxCompletionTokens, _calculatePromptLength(messages));
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
        uint256 promptLength = _calculatePromptLength(messages);
        uint256 completionCost = _calculateCompletionCostCalldata(model, maxCompletionTokens, promptLength);
        require(msg.value >= completionCost, InsufficientPayment());

        // Effects
        completionId = _completions.length;
        _completions.push(
            Completion({paidAmount: msg.value, promptLength: promptLength, callback: callback, done: false})
        );

        // Interactions
        callCoprocessor(abi.encode(completionId, model, maxCompletionTokens, messages, options));
    }

    function handleNotice(bytes32, bytes memory notice) internal override {
        // Checks
        uint256 completionId;
        string memory model;
        Message[] memory messages;
        Usage memory usage;

        (completionId, model, messages, usage) = abi.decode(notice, (uint256, string, Message[], Usage));

        Completion storage completion = _completions[completionId];

        require(!completion.done, CompletionAlreadyDone());

        uint256 completionCost = _calculateCompletionCostMemory(model, usage.completionTokens, completion.promptLength);
        uint256 refund;

        if (completion.paidAmount > completionCost) {
            refund = completion.paidAmount - completionCost;
        }

        // Effects
        completion.done = true;
        _lockedAmount += completion.paidAmount - refund;

        // Interactions
        completion.callback.receiveResult{value: refund}(completionId, messages, usage);
    }

    function withdrawLockedAmount() external {
        // Effects
        uint256 value = _lockedAmount;
        _lockedAmount = 0;

        // Interactions
        (bool success,) = _lockedAmountRecipient.call{value: value}("");
        require(success, FailedWithdrawal());
    }

    function _calculatePromptLength(Message[] calldata messages) internal pure returns (uint256 sum) {
        for (uint256 i; i < messages.length; ++i) {
            sum += messages[i].content.length;
        }
    }

    function _calculateCompletionCostCalldata(string calldata model, uint256 maxCompletionTokens, uint256 promptLength)
        internal
        pure
        returns (uint256)
    {
        return _calculateCompletionCostMemory(model, maxCompletionTokens, promptLength);
    }

    function _calculateCompletionCostMemory(string memory, uint256, uint256) internal pure returns (uint256) {
        return 0; // dummy value
    }
}
