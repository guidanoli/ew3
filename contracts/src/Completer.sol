// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.28;

import {Message, Option} from "./Types.sol";
import {Callback} from "./Callback.sol";

interface Completer {
    /// @notice Ask a LLM to complete
    /// @return completionId A chat completion ID
    function askForCompletion(
        string calldata modelName,
        uint256 maxCompletionTokens,
        Message[] calldata messages,
        Option[] calldata options,
        Callback callback
    ) external returns (uint256 completionId);
}
