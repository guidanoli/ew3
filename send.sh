#!/usr/bin/env bash
set -euo pipefail
if [ $# -ge 1 ]
then
    original_request_json_path=$(readlink -f "$1")
    shift 1
else
    >&2 echo "Usage: $0 <request JSON path>"
    exit 1
fi
cd contracts
mkdir -p requests
request_json_path=$(mktemp requests/XXXXXX.json)
cp "$original_request_json_path" "$request_json_path"
mkdir -p completionIds
completion_id_file_path=$(mktemp completionIds/XXXXXX)
CoprocessorCompleter=$(cat deployments/CoprocessorCompleter)
SimpleCallback=$(cat deployments/SimpleCallback)
forge script "$@" --broadcast SendScript --sig 'send(address,address,string,string)' "$CoprocessorCompleter" "$SimpleCallback" "$request_json_path" "$completion_id_file_path"
rm "$request_json_path"
mv "$completion_id_file_path" "$original_request_json_path.completionId"
