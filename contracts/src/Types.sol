// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.28;

/// @notice A role
enum Role {
    ROLE_SYSTEM,
    ROLE_ASSISTANT,
    ROLE_USER
}

/// @notice A message from someone
/// @notice content is a UTF-8 encoded byte array
struct Message {
    Role role;
    bytes content;
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

/// @notice Completion request
struct Request {
    string model;
    uint256 maxCompletionTokens;
    Message[] messages;
    Option[] options;
}

/// @notice Completion result
struct Result {
    uint256 completionId;
    Message[] messages;
    Usage usage;
}
