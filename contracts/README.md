# ThinkChain contracts

This is documentation about the contracts that support ThinkChain.
Below, we have carefully laid out the topics in topological order.

## [`Types.sol`](./src/Types.sol)

This file defines types that are used by interfaces and contracts.

### `Message` (struct)

This structure defines a message.
It contains two string fields, `content` and `role`, in this order.
The role should be either `system`, `assistant` or `user`.
Meanwhile, `content` can be any UTF-8 string.

### `Option` (struct)

This structure defines a model option.
Configuration is usually represented by a key-value mapping,
however Solidity disallows mappings as functions arguments.
Because of this, we encode mappings as array sof key-value pairs.
This structure has two string fields, `key` and `value`, in this order.
Both are arbitrary UTF-8 strings.
The value field can also encode integers and floating-point numbers in string form.
For example: `"42"` and `"0.8"`.

### `Usage` (struct)

This structure defines a usage report.
After a model is run, such statistics are commonly output.
It defines two unsigned 256-bit integer (`uint256`) fields, `promptTokens` and `completionTokens`, in this order.
As the name may suggest, `promptTokens` is the number of prompt tokens taken by the model.
Likewise, `completionTokens` is the number of completion tokens output by the model.

### `Request` (struct)

This structure defines a completion request.
It is provided to the completer contract when estimating the request cost, and when performing the request effectively.
It contains four fields.
The first field is an unsigned 256-bit integer named `maxCompletionTokens`,
which is the maximum number of completion tokens allowed by the model to output.
This field aims to limit the processing time, and also to give a cost estimation to be computed on-chain.
The second field is a list of messages, typed as `Message[]`.
The third field is a string which encodes the model name.
The names of available models can be derived from `RegisteredModel` events in the `Completer` interface.
The fourth and last field is a list of options, typed as `Option[]`.

## [`Callback.sol`](./src/Callback.sol)

This file defines the `Callback` interface, which is called whenever a completion request is fulfilled by an operator.

### `ResultReceived` (event)

This event is emitted whenever a result is received (someone calls the `receiveResult`).
It contains six arguments.
The first argument is the completion ID and it is _indexed_.
The second argument is the caller address and it is also _indexed_.
This argument aims to avoid malicious actors from messing with applications.
Knowing the completer contract address, you should filter events by this indexed argument.
The third argument is the requester address, that is, the address of the account that originally issued the completion request.
The fourth argument is the reimbursed value, if any (it may be zero).
The callback contract is bound to reimburse the original requester with this value.
The fifth argument is the list of messages generated/completed by the LLM.
This does not include the messages originally provided by the requester.
The sixth and last argument is the usage report.

### `receiveResult` (payable function)

This function is called by the completer contract once the completion request is fulfilled.
It receives the completion ID, the requester address, the list of completed messages, and the usage report.
If the amount payed by the requester is greater than the actual cost (which depends on the actual number of prompt tokens),
then the difference is passed along the call to the callback contract, which then forwards to the requester.

## [`Completer.sol`](./src/Completer.sol)

This file defines the `Completer` interface, which is inherited by the `CoprocessorCompleter` contract.

### `InsufficientPayment` (error)

Error raised when `requestCompletion` is called with a value (in Ether) lower than the cost.
The cost can be calculated by calling the `getCompletionRequestCost` function beforehand.
The error includes two arguments: the estimated request cost, and the payment value (lower than the cost).

### `RegisteredModel` (event)

An event emitted whenever a new model is registered and available for completion requests.
The only argument is the model name, which should be passed as-is when requesting completions.

### `getCompletionRequestCost` (view function)

This view function should be used to estimate the cost of a completion before requesting it.
It takes in a request as argument and returns the cost in Wei (the smallest denomination of Ether).
Because tokenization happens only off-chain, the completer contract usually overshoots the cost so that it can refund the difference later, upon completion.

### `requestCompletion` (payable function)

This function is the entrypoint used to request completions.
It takes in a request and the address of a callback contract to be called once the request is fulfilled.
It should also receive as value the completion request cost, which can be estimated via the `getCompletionRequestCost` function.
If it receives less than this value, it raises an `InsufficientPayment` error (and therefore reverting any value transfer).
In case of success, it returns the ID of the completion request, which will be passed to the callback contract upon processing.
This ID unique identifies to the completion request, as it is to be expected of an ID.
Once the request is fulfilled, the completer contract will call the callback contract with the same completion ID,
along with the completed messages, the usage report, and any difference between the upfront payment and the actual cost of the completion job.
