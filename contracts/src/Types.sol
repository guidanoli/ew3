// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.28;

/// @notice A message from someone
struct Message {
    string content;
    string role;
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
    uint256 maxCompletionTokens;
    Message[] messages;
    string model;
    Option[] options;
}
