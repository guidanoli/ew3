// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.28;

import {Message, Option} from "./Types.sol";

interface Completer {
    /// @notice Ask a LLM to complete
    /// @dev Enough Ether must be provided
    /// @return A chat completion ID
    function askCompletion(
        string calldata model,
        uint256 maxCompletionTokens,
        Message[] calldata messages,
        Option[] calldata options
    ) external payable returns (uint256);

    /// @notice Returns the amount of Wei necessary to call
    /// `askCompletion` with the same parameters.
    function estimateCompletionCost(
        string calldata model,
        uint256 maxCompletionTokens,
        Message[] calldata messages,
        Option[] calldata options
    ) external view returns (uint256);
}
