# Experiment Week 3 Project

## Setup

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
In order to deploy it, you can run the [`deploy.sh`](./deploy.sh) Shell script while on the project root.
It is basically a wrapper around a [`forge script`](https://book.getfoundry.sh/reference/forge/forge-create) command that provides the correct the arguments.
Beware that, when running this Shell script, you must provide the deployer private key through the `PRIVATE_KEY` environment variable.
Below is an example for deploying to a local devnet.

```sh
export PRIVATE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
./deploy.sh --fork-url http://127.0.0.1:8545/
```

This command will create a `contracts/deployments/CoprocessorCompleter` file, which will contain the address of the newly-deployed `CoprocessorCompleter` contract.
