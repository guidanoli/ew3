# ThinkChain

ThinkChain is an on-chain service that enables smart contracts to perform _verifiable_ large language model (LLM) inference.
The service provides access to a variety of popular LLMs, such as DeepSeek-R1, DeepScaleR, Qwen2.5 and SmolLM2.
A simple Solidity interface makes it easy for smart contracts to construct prompts and decode replies entirely on-chain.
Completion requests are charged in Ether.

_Client_ contracts send completion requests to the _Completer_ contract, which issues tasks to EigenLayer operators.
Operators run the selected inference model inside a Cartesi Machine to guarantee determinism.
Results are then signed by operators, and an aggregated signature is submitted to a solver.
Once the solver submits the signed result on-chain, the _Completer_ forwards it to a _Callback_ contract, designated by the _Client_.

ThinkChain is suitable for smart contracts that would benefit from on-chain access to LLMs for decision making, data analysis, content generation, or any other goal.
_Client_ contracts can propagate the cost of using the service to their users, and even charge extra for their services.
No matter the problem, ThinkChain has a model suitable for your use case.

## Setup

This repository contains [git submodules](https://git-scm.com/book/en/v2/Git-Tools-Submodules).
In order to properly initialize them, please, run the following command.

```sh
git submodule update --init --recursive
```

Make sure you have all the [dependencies](https://docs.mugen.builders/cartesi-co-processor-tutorial/installation) installed.
If you don't want to install the Cartesi CLI globally, you can do `pnpm i`
and store the following code in an executable file named `cartesi` somewhere accessible by your `PATH` environment variable:

```sh
#!/usr/bin/env bash
pnpm exec cartesi "$@"
```

## Starting up a devnet

In order to test the application locally, you first need to start up a devnet.
You can do so by running the following command on the project root.
This might take a while.

```sh
cartesi-coprocessor start-devnet
```

You can then later stop the devnet at any time by running the following command on the project root.
This command can be really useful if you run into some error, and you have to restart your local devnet.

```sh
cartesi-coprocessor stop-devnet
```

## Publishing

Once your devnet is running, you can publish the machine by running the following command on the project root.

```sh
cartesi-coprocessor publish --network devnet
```

## Deployment

The main contract in the project is called [`CoprocessorCompleter`](./contracts/src/CoprocessorCompleter.sol).
Another useful contract is [`SimpleCallback`](./contracts/src/SimpleCallback.sol), which, as the name may imply, is a simple callback contract example.
In order to deploy them, you can run the [`deploy.sh`](./deploy.sh) Shell script while on the project root.
It is basically a wrapper around a [`forge script`] command that provides the correct the arguments.
Beware that, when running this Shell script, you must provide the deployer private key through the `PRIVATE_KEY` environment variable.
Below is an example for deploying to a local devnet.

```sh
export PRIVATE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
./deploy.sh --fork-url localhost:8545
```

This command will create `contracts/deployments/<ContractName>` files for each deployed contract, contain their respective addresses.

### Model costs

Model costs are defined in the `models.json` file.
If you would like to tweak the costs, simply edit the file, and new deployings should use the new values.

## Sending tasks

After deploying the necessary contracts, you can now send tasks to the operator through the [`send.sh`](./send.sh) Shell script.
The script takes one positional argument: the path of a JSON file with the completion request details.
The schema of this JSON file can be deduced from [this example](./examples/request.json).
And, just like the deployment script, this script is also a wrapper around [`forge script`],
which means that you can provide any extra options after the positional argument.
Also, make sure the `PRIVATE_KEY` environment variable is set to the private key of an account with some Ether.

```sh
export PRIVATE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
./send.sh examples/request.json --fork-url localhost:8545
```

You should see the operator processing the input from the Docker Desktop UI.
This command will create a `examples/request.json.completionId` with the completion ID of the request for future reference.
You can delete this file afterwards, if you want.

## Getting results back

After your task is sent to the operator, a result should soon be posted back on-chain.
If your task was sent using the method from the previous step, then you should be able to get your result back from the logs.
However, parsing the event logs is not very straightforward with `cast`.
Instead, we recommend you use the `getresult.sh` Shell script, and pass the completion ID as argument.
This Shell script is as a wrapper around a [`cast logs`] command. Any extra arguments are passed to it.

```sh
./getresult.sh $(cat examples/request.json.completionId)
```

[`forge script`]: https://book.getfoundry.sh/reference/forge/forge-script
[`cast logs`]: https://book.getfoundry.sh/reference/cast/cast-logs

## Starting frontend

```
cd frontend
npm install
npm run dev
```
