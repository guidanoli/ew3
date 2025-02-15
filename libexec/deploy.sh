#!/usr/bin/env bash
set -euo pipefail
address_book=$(cartesi-coprocessor address-book)
task_issuer=$(echo "$address_book" | awk '$1 == "Devnet_task_issuer" { print $2 }')
machine_hash=$(echo "$address_book" | awk '$1 == "Machine" && $2 == "Hash" { print $3 }')
original_models_json_path=$(readlink -f models.json)
cost_multiplier=$(cast to-wei 400 gwei)
cd contracts
mkdir -p models
models_json_path=$(mktemp models/XXXXXX.json)
cp "$original_models_json_path" "$models_json_path"
forge script "$@" --broadcast DeployScript --sig 'deploy(address,bytes32,string,uint256)' "$task_issuer" "$machine_hash" "$models_json_path" "$cost_multiplier"
rm "$models_json_path"
