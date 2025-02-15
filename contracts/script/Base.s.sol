// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.28;

import {Script} from "forge-std/Script.sol";

contract BaseScript is Script {
    uint256 DEFAULT_PRIVATE_KEY = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;

    function _getPrivateKey() internal view returns (uint256) {
        return vm.envOr("PRIVATE_KEY", DEFAULT_PRIVATE_KEY);
    }
}
