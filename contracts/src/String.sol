// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.28;

library String {
    function hash(string memory str) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(str));
    }
}
