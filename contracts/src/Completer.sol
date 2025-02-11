// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.28;

import {Message, Option} from "./Types.sol";
import {Callback} from "./Callback.sol";

interface Completer {
    /// @notice Returns an estimated amount of Wei necessary
    /// to request a completion
    function calculateCompletionCost(bytes32 modelHash, uint256 maxCompletionTokens, uint256 promptLength)
        external
        view
        returns (uint256);

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
