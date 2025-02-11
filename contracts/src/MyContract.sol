// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "../lib/coprocessor-base-contract/src/CoprocessorAdapter.sol";

contract MyContract is CoprocessorAdapter {
    constructor(address _taskIssuerAddress, bytes32 _machineHash)
        CoprocessorAdapter(_taskIssuerAddress, _machineHash)
    {}

    function runExecution(bytes calldata input) external {
        callCoprocessor(input);
    }

    function handleNotice(bytes32 payloadHash, bytes memory notice) internal override {
        // Add logic for handling callback from co-processor containing notices.
    }

    // Add your other app logic here
}
