// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.28;

import {Message, Usage} from "./Types.sol";

interface Callback {
    /// @notice A result was received
    event ResultReceived(
        uint256 indexed completionId,
        address indexed caller,
        address requester,
        uint256 value,
        Message[] messages,
        Usage usage
    );

    /// @notice Receive completion result back
    /// @dev Might come with change in Wei, which should be forwarded to the requester
    function receiveResult(uint256 completionId, address requester, Message[] calldata messages, Usage calldata usage)
        external
        payable;

    /// @notice Get number of block in which the contract was deployed
    function getDeploymentBlockNumber() external view returns (uint256);
}
