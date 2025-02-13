// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.28;

import {Callback} from "./Callback.sol";
import {Message, Usage} from "./Types.sol";

contract SimpleCallback is Callback {
    event ResultReceived(uint256 indexed completionId, Message[] messages, Usage usage);

    /// @inheritdoc Callback
    function receiveResult(uint256 completionId, Message[] calldata messages, Usage calldata usage)
        external
        payable
        override
    {
        emit ResultReceived(completionId, messages, usage);
    }
}
