#!/usr/bin/env bash
set -euo pipefail
address_book=$(cartesi-coprocessor address-book)
task_issuer=$(echo "$address_book" | awk '$1 == "Devnet_task_issuer" { print $2 }')
machine_hash=$(echo "$address_book" | awk '$1 == "Machine" && $2 == "Hash" { print $3 }')
cd contracts
forge create "$@" CoprocessorCompleter --constructor-args "$task_issuer" "$machine_hash"
