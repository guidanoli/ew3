#!/usr/bin/env bash
set -euo pipefail
[ $# -ge 1 ] || (>&2 echo "Usage: $0 <completion ID>" && exit 1)
completion_id=$1
shift 1
SimpleCallback=$(cat contracts/deployments/SimpleCallback)
CoprocessorCompleter=$(cat contracts/deployments/CoprocessorCompleter)
ResultReceived='ResultReceived(uint256 indexed,address indexed,address,uint256,(string,string)[],(uint256,uint256))'
logs=$(cast logs "$@" --json --address "$SimpleCallback" "$(cast sig-event "$ResultReceived")" "$(cast to-uint256 "$completion_id")" "$CoprocessorCompleter")
nlogs=$(echo "$logs" | jq length)
[ $nlogs -ge 1 ] || (>&2 echo "No result for completion #$completion_id yet." && exit 1)
log_data=$(echo "$logs"| jq -r '.[0].data')
cast event-decode --sig "$ResultReceived" "$log_data"
