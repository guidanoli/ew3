// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.28;

import {Message, Option} from "./Types.sol";
import {Callback} from "./Callback.sol";

interface Completer {
    /// @notice Returns the amount of Wei necessary to call
    /// `askCompletion` with the same parameters.
    function calculateCompletionCost(
        string calldata model,
        uint256 maxCompletionTokens,
        Message[] calldata messages,
        Option[] calldata options
    ) external view returns (uint256);

    /// @notice Ask a LLM to complete
    /// @dev Enough Ether must be provided
    /// @return completionId A chat completion ID
    function askCompletion(
        string calldata model,
        uint256 maxCompletionTokens,
        Message[] calldata messages,
        Option[] calldata options,
        Callback callback
    ) external payable returns (uint256 completionId);
}
