# Experiment Week 3 Project

## Setup

Make sure you have all the [dependencies](https://docs.mugen.builders/cartesi-co-processor-tutorial/installation) installed.
If you don't want to install the Cartesi CLI globally, you can do `pnpm i` and have the following file in your `PATH`:

```sh
#!/usr/bin/env bash
pnpm exec cartesi "$@"
```

## Deployment

In order to deploy the [`CoprocessorCompleter`](./contracts/src/CoprocessorCompleter.sol) contract, you can use the [`deploy.sh`](./deploy.sh) Shell script.
It is basically a wrapper around a [`forge create`](https://book.getfoundry.sh/reference/forge/forge-create) command that provides the correct the constructor arguments.
You only have to provide the deployer credentials, which may vary depending on the type of network.

### Devnet

For a local devnet, you can use any of the dummy accounts provided.
In the command below, we use `cast` and `jq` to extract the first account from the list.

```sh
./deploy.sh --broadcast --unlocked --from $(cast rpc eth_accounts | jq -r '.[0]')
```
