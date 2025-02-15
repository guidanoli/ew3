export type Message = {
    content: string;
    role: string;
}

export type Option = {
    key: string;
    value: string;
}

export type Request = {
    maxCompletionTokens: number;
    messages: Message[];
    model: string;
    options: Option[];
}

export const ABI_COMPLETER = [
    {
        "type": "function",
        "name": "getCompletionRequestCost",
        "inputs": [
            {
                "name": "request",
                "type": "tuple",
                "internalType": "struct Request",
                "components": [
                    {
                        "name": "maxCompletionTokens",
                        "type": "uint256",
                        "internalType": "uint256"
                    },
                    {
                        "name": "messages",
                        "type": "tuple[]",
                        "internalType": "struct Message[]",
                        "components": [
                            {
                                "name": "content",
                                "type": "string",
                                "internalType": "string"
                            },
                            {
                                "name": "role",
                                "type": "string",
                                "internalType": "string"
                            }
                        ]
                    },
                    {
                        "name": "model",
                        "type": "string",
                        "internalType": "string"
                    },
                    {
                        "name": "options",
                        "type": "tuple[]",
                        "internalType": "struct Option[]",
                        "components": [
                            {
                                "name": "key",
                                "type": "string",
                                "internalType": "string"
                            },
                            {
                                "name": "value",
                                "type": "string",
                                "internalType": "string"
                            }
                        ]
                    }
                ]
            }
        ],
        "outputs": [
            {
                "name": "",
                "type": "uint256",
                "internalType": "uint256"
            }
        ],
        "stateMutability": "view"
    },
    {
        "type": "function",
        "name": "requestCompletion",
        "inputs": [
            {
                "name": "request",
                "type": "tuple",
                "internalType": "struct Request",
                "components": [
                    {
                        "name": "maxCompletionTokens",
                        "type": "uint256",
                        "internalType": "uint256"
                    },
                    {
                        "name": "messages",
                        "type": "tuple[]",
                        "internalType": "struct Message[]",
                        "components": [
                            {
                                "name": "content",
                                "type": "string",
                                "internalType": "string"
                            },
                            {
                                "name": "role",
                                "type": "string",
                                "internalType": "string"
                            }
                        ]
                    },
                    {
                        "name": "model",
                        "type": "string",
                        "internalType": "string"
                    },
                    {
                        "name": "options",
                        "type": "tuple[]",
                        "internalType": "struct Option[]",
                        "components": [
                            {
                                "name": "key",
                                "type": "string",
                                "internalType": "string"
                            },
                            {
                                "name": "value",
                                "type": "string",
                                "internalType": "string"
                            }
                        ]
                    }
                ]
            },
            {
                "name": "callback",
                "type": "address",
                "internalType": "contract Callback"
            }
        ],
        "outputs": [
            {
                "name": "completionId",
                "type": "uint256",
                "internalType": "uint256"
            }
        ],
        "stateMutability": "payable"
    },
    {
        "type": "error",
        "name": "InsufficientPayment",
        "inputs": [
            {
                "name": "cost",
                "type": "uint256",
                "internalType": "uint256"
            },
            {
                "name": "payment",
                "type": "uint256",
                "internalType": "uint256"
            }
        ]
    }
];

export const ABI_SIMPLE_CALLBACK = [
    {
        "type": "function",
        "name": "receiveResult",
        "inputs": [
            {
                "name": "completionId",
                "type": "uint256",
                "internalType": "uint256"
            },
            {
                "name": "requester",
                "type": "address",
                "internalType": "address"
            },
            {
                "name": "messages",
                "type": "tuple[]",
                "internalType": "struct Message[]",
                "components": [
                    {
                        "name": "content",
                        "type": "string",
                        "internalType": "string"
                    },
                    {
                        "name": "role",
                        "type": "string",
                        "internalType": "string"
                    }
                ]
            },
            {
                "name": "usage",
                "type": "tuple",
                "internalType": "struct Usage",
                "components": [
                    {
                        "name": "promptTokens",
                        "type": "uint256",
                        "internalType": "uint256"
                    },
                    {
                        "name": "completionTokens",
                        "type": "uint256",
                        "internalType": "uint256"
                    }
                ]
            }
        ],
        "outputs": [],
        "stateMutability": "payable"
    },
    {
        "type": "event",
        "name": "ResultReceived",
        "inputs": [
            {
                "name": "completionId",
                "type": "uint256",
                "indexed": true,
                "internalType": "uint256"
            },
            {
                "name": "caller",
                "type": "address",
                "indexed": true,
                "internalType": "address"
            },
            {
                "name": "requester",
                "type": "address",
                "indexed": false,
                "internalType": "address"
            },
            {
                "name": "value",
                "type": "uint256",
                "indexed": false,
                "internalType": "uint256"
            },
            {
                "name": "messages",
                "type": "tuple[]",
                "indexed": false,
                "internalType": "struct Message[]",
                "components": [
                    {
                        "name": "content",
                        "type": "string",
                        "internalType": "string"
                    },
                    {
                        "name": "role",
                        "type": "string",
                        "internalType": "string"
                    }
                ]
            },
            {
                "name": "usage",
                "type": "tuple",
                "indexed": false,
                "internalType": "struct Usage",
                "components": [
                    {
                        "name": "promptTokens",
                        "type": "uint256",
                        "internalType": "uint256"
                    },
                    {
                        "name": "completionTokens",
                        "type": "uint256",
                        "internalType": "uint256"
                    }
                ]
            }
        ],
        "anonymous": false
    }
];
