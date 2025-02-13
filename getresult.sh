#!/usr/bin/env bash
set -euo pipefail
[ $# -ge 1 ] || (>&2 echo "Usage: $0 <completion ID>" && exit 1)
completion_id=$1
shift 1
SimpleCallback=$(cat contracts/deployments/SimpleCallback)
ResultReceived='ResultReceived(uint256 indexed,(string,string)[],(uint256,uint256))'
logs=$(cast logs "$@" --json --address "$SimpleCallback" "$(cast sig-event "$ResultReceived")" "$(cast to-uint256 "$completion_id")")
nlogs=$(echo "$logs" | jq length)
[ $nlogs -ge 1 ] || (>&2 echo "No result for completion #$completion_id yet." && exit 1)
log_data=$(echo "$logs"| jq -r '.[0].data')
cast event-decode --sig "$ResultReceived" "$log_data"
