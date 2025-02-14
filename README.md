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

## Features

- Access to a wide variety of LLMs
- Simple Solidity interface
- Configurable inference options
- Fast finality
- Accepts payments in Ether

## Getting Started

First, please make sure your machine contains all the necessary [dependencies](https://docs.mugen.builders/cartesi-co-processor-tutorial/installation).
Then, clone this repository and its [submodules](https://git-scm.com/book/en/v2/Git-Tools-Submodules) recursively.

```sh
git clone --recurse-submodules https://github.com/guidanoli/thinkchain.git
```

In order to run ThinkChain locally, you first need to start up a devnet.

```sh
cartesi-coprocessor start-devnet
```

> [!NOTE]
> You can stop the devnet at any time by running the following command.
> It might be useful if you run into some error and need to restart the devnet.
> ```sh
> cartesi-coprocessor stop-devnet
> ```

Once the devnet is up, you may publish the machine.

```sh
cartesi-coprocessor publish --network devnet
```

Then, you may deploy the contracts.

```sh
export PRIVATE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
./deploy.sh --fork-url localhost:8545
```

Once the contracts are deployed, you can send a completion request on-chain.
We'll choose an example request but you can provide any.

```sh
export PRIVATE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
./send.sh examples/request.json --fork-url localhost:8545
```

Once the request is fulfilled, you can retrieve the result.

```sh
./getresult.sh $(cat examples/request.json.completionId)
```

## Starting frontend

```
cd frontend
npm install
npm run dev
```
