// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.28;

library Error {
    /// @notice Raise error data
    /// @param errordata Data returned by failed low-level call
    function raise(bytes memory errordata) internal pure {
        if (errordata.length == 0) {
            revert();
        } else {
            assembly {
                revert(add(32, errordata), mload(errordata))
            }
        }
    }
}
