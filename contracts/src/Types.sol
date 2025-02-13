// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.28;

/// @notice A role
enum Role {
    SYSTEM,
    ASSISTANT,
    USER
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

/// @notice LLM completion request
struct Request {
    string modelName;
    uint256 maxCompletionTokens;
    Message[] messages;
    Option[] options;
}
