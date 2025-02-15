#!/usr/bin/env bash
set -euo pipefail
if [ $# -ge 1 ]
then
    completion_id_file_path=$(readlink -f "$1")
    shift 1
else
    >&2 echo "Usage: $0 <completion ID file path>"
    exit 1
fi
completion_id=$(cat "$completion_id_file_path")
cd contracts
mkdir -p results
result_json_path=$(mktemp results/XXXXXX.json)
SimpleCallback=$(cat deployments/SimpleCallback)
CoprocessorCompleter=$(cat deployments/CoprocessorCompleter)
forge script "$@" GetResultScript --sig 'getResult(address,uint256,address,string)' "$SimpleCallback" "$completion_id" "$CoprocessorCompleter" "$result_json_path"
mv "$result_json_path" "$completion_id_file_path.result"
