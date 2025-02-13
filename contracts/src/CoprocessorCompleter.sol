// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.28;

import {CoprocessorAdapter} from "coprocessor-base-contract/CoprocessorAdapter.sol";

import {Request, Message, Option, Usage} from "./Types.sol";
import {Callback} from "./Callback.sol";
import {Completer} from "./Completer.sol";

contract CoprocessorCompleter is CoprocessorAdapter, Completer {
    uint256 nextCompletionId;

    struct ModelCostTable {
        uint256 perCompletionToken;
        uint256 perPromptToken;
    }

    mapping(string => ModelCostTable) public modelCostTables;

    mapping(uint256 => uint256) public completionPayments;

    struct Model {
        ModelCostTable costs;
        string name;
    }

    constructor(address taskIssuer, bytes32 machineHash, Model[] memory models)
        CoprocessorAdapter(taskIssuer, machineHash)
    {
        for (uint256 i; i < models.length; ++i) {
            Model memory model = models[i];
            modelCostTables[model.name] = model.costs;
        }
    }

    /// @inheritdoc Completer
    function getCompletionRequestCost(Request calldata request) public view override returns (uint256) {
        ModelCostTable storage modelCostTable = modelCostTables[request.model];
        uint256 maxPromptTokens = _calculateMaxPromptTokens(request.messages);
        uint256 maxCompletionTokens = request.maxCompletionTokens;
        return _calculateCompletionCost(modelCostTable, maxPromptTokens, maxCompletionTokens);
    }

    /// @inheritdoc Completer
    function requestCompletion(Request calldata request, Callback callback)
        external
        payable
        override
        returns (uint256 completionId)
    {
        uint256 cost = getCompletionRequestCost(request);
        uint256 payment = msg.value;
        require(cost <= payment, InsufficientPayment(cost, payment));
        completionId = nextCompletionId++;
        completionPayments[completionId] = payment;
        callCoprocessor(
            abi.encode(
                completionId, request.model, request.maxCompletionTokens, request.messages, request.options, callback
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

    /// @notice Calculate the maximum number of prompt tokens from a list of messages
    /// @dev We use the sum of the message lengths as the upper bound
    function _calculateMaxPromptTokens(Message[] calldata messages) internal pure returns (uint256 sum) {
        for (uint256 i; i < messages.length; ++i) {
            Message calldata message = messages[i];
            sum += bytes(message.content).length;
        }
    }

    /// @notice Calculate the completion cost from a model cost table and number of prompt and completion tokens
    function _calculateCompletionCost(
        ModelCostTable storage modelCostTable,
        uint256 promptTokens,
        uint256 completionTokens
    ) internal view returns (uint256) {
        return promptTokens * modelCostTable.perPromptToken + completionTokens * modelCostTable.perCompletionToken;
    }
}
