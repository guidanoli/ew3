// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.28;

import {Request} from "./Types.sol";
import {Callback} from "./Callback.sol";

interface Completer {
    /// @notice Payment is less than cost
    error InsufficientPayment(uint256 cost, uint256 payment);

    /// @notice A model with such name has been registered
    event RegisteredModel(string model);

    /// @notice Get the cost (in Wei) of requesting a completion
    function getCompletionRequestCost(Request calldata request) external view returns (uint256);

    /// @notice Ask a LLM to complete
    /// @return completionId A chat completion ID
    function requestCompletion(Request calldata request, Callback callback)
        external
        payable
        returns (uint256 completionId);
}
