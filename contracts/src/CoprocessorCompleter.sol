// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.28;

import {CoprocessorAdapter} from "coprocessor-base-contract/CoprocessorAdapter.sol";

import {Request, Message, Option, Usage} from "./Types.sol";
import {Callback} from "./Callback.sol";
import {Completer} from "./Completer.sol";
import {Math} from "./Math.sol";
import {String} from "./String.sol";

contract CoprocessorCompleter is CoprocessorAdapter, Completer {
    using Math for uint256;
    using String for string;

    uint256 constant maxInjectedPromptTokens = 30;

    uint256 nextCompletionId;

    struct ModelCostTable {
        uint256 perCompletionToken;
        uint256 perPromptToken;
    }

    mapping(bytes32 => ModelCostTable) public modelCostTables;

    struct PaymentReceipt {
        bytes32 modelHash;
        uint256 value;
    }

    mapping(uint256 => PaymentReceipt) public paymentReceipts;

    struct Model {
        ModelCostTable costs;
        string name;
    }

    constructor(address taskIssuer, bytes32 machineHash, Model[] memory models)
        CoprocessorAdapter(taskIssuer, machineHash)
    {
        for (uint256 i; i < models.length; ++i) {
            Model memory model = models[i];
            modelCostTables[model.name.hash()] = model.costs;
            emit RegisteredModel(model.name);
        }
    }

    /// @inheritdoc Completer
    function getCompletionRequestCost(Request calldata request) public view override returns (uint256 cost) {
        (, cost) = _getCompletionRequestCost(request);
    }

    /// @inheritdoc Completer
    function requestCompletion(Request calldata request, Callback callback)
        external
        payable
        override
        returns (uint256 completionId)
    {
        (bytes32 modelHash, uint256 cost) = _getCompletionRequestCost(request);
        uint256 payment = msg.value;
        require(cost <= payment, InsufficientPayment(cost, payment));
        completionId = nextCompletionId++;
        paymentReceipts[completionId] = PaymentReceipt({modelHash: modelHash, value: payment});
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
        PaymentReceipt storage paymentReceipt = paymentReceipts[completionId];
        ModelCostTable storage modelCostTable = modelCostTables[paymentReceipt.modelHash];
        uint256 cost = _calculateCompletionCost(modelCostTable, usage.promptTokens, usage.completionTokens);
        uint256 refund = paymentReceipt.value.monus(cost).min(address(this).balance);
        callback.receiveResult{value: refund}(completionId, messages, usage);
    }

    /// @notice Calculate and return the hash of the model name, and calculate the completion request cost
    function _getCompletionRequestCost(Request calldata request)
        internal
        view
        returns (bytes32 modelHash, uint256 cost)
    {
        modelHash = request.model.hash();
        ModelCostTable storage modelCostTable = modelCostTables[modelHash];
        uint256 maxPromptTokens = _calculateMaxPromptTokens(request.messages);
        uint256 maxCompletionTokens = request.maxCompletionTokens;
        cost = _calculateCompletionCost(modelCostTable, maxPromptTokens, maxCompletionTokens);
    }

    /// @notice Calculate the maximum number of prompt tokens from a list of messages
    /// @dev We use the sum of the message lengths as the upper bound
    function _calculateMaxPromptTokens(Message[] calldata messages) internal pure returns (uint256 sum) {
        sum = maxInjectedPromptTokens;
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
