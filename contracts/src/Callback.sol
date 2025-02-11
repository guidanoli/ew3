// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.28;

import {Message, Usage} from "./Types.sol";

interface Callback {
    /// @notice Receive completion result back
    /// @dev Might come with change in Wei
    function receiveResult(
        uint256 chatCompletionId,
        Message[] calldata messages,
        Usage calldata usage
    ) external payable;
}
