// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.28;

library Math {
    function monus(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a > b) {
            unchecked {
                return a - b;
            }
        } else {
            return 0;
        }
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return (a < b) ? a : b;
    }
}
