// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.28;

/// @notice A role
enum Role {
    ROLE_SYSTEM,
    ROLE_ASSISTANT,
    ROLE_USER
}

/// @notice A message from someone
struct Message {
    Role role;
    string content;
}

/// @notice Extra LLM options
struct Option {
    string key;
    string value;
}

/// @notice LLM usage statistics
struct Usage {
    uint256 promptTokens;
    uint256 completionTokens;
}
 

