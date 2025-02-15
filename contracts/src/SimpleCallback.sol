// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.28;

import {Callback} from "./Callback.sol";
import {Message, Usage} from "./Types.sol";
import {Error} from "./Error.sol";

contract SimpleCallback is Callback {
    using Error for bytes;

    uint256 immutable _deploymentBlockNumber = block.number;

    /// @inheritdoc Callback
    function receiveResult(uint256 completionId, address requester, Message[] calldata messages, Usage calldata usage)
        external
        payable
        override
    {
        bool success;
        bytes memory returndata;

        (success, returndata) = requester.call{value: msg.value}("");

        if (!success) {
            returndata.raise();
        }

        emit ResultReceived(completionId, msg.sender, requester, msg.value, messages, usage);
    }

    /// @inheritdoc Callback
    function getDeploymentBlockNumber() external view override returns (uint256) {
        return _deploymentBlockNumber;
    }
}
