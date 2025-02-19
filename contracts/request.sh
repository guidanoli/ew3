#!/usr/bin/env bash
set -euo pipefail
green='\e[32m%s\e[0m\n'
## model
models=$(jq '[.[].name]' models.json)
modelCount=$(echo "$models" | jq length)
echo "$models" | jq -r 'to_entries[] | "\(.key). \(.value)"'
defaultModelNum=0
while true
do
    read -p "Choose a model (integer between 0 and $((modelCount - 1)), default is $defaultModelNum): " modelIndex
    if [[ -z "$modelIndex" ]]
    then
        modelIndex=$defaultModelNum
    fi
    if [[ "$modelIndex" =~ ^[0-9]+$ ]]
    then
        if [[ "$modelIndex" -lt "$modelCount" ]]
        then
            model=$(echo "$models" | jq -r ".[$modelIndex]")
            break
        else
            >&2 echo "Not a valid integer"
        fi
    else
        >&2 echo "Not a positive integer"
    fi
done
printf "$green" "Model: $model"
## maxCompletionTokens
defaultMaxCompletionTokens=10
while true
do
    read -p "Define the maximum number of completion tokens (positive integer, default is $defaultMaxCompletionTokens): " maxCompletionTokens
    if [[ -z "$maxCompletionTokens" ]]
    then
        maxCompletionTokens=$defaultMaxCompletionTokens
    fi
    if [[ "$maxCompletionTokens" =~ ^[0-9]+$ ]]
    then
        break
    else
        >&2 echo "Not a positive integer"
    fi
done
printf "$green" "MaxCompletionTokens: $maxCompletionTokens"
### systemPrompt
defaultSystemPrompt="You are a helpful assistant"
read -p "Write a system prompt (default is '$defaultSystemPrompt'): " systemPrompt
if [[ -z "$systemPrompt" ]]
then
    systemPrompt=$defaultSystemPrompt
fi
printf "$green" "SystemPrompt: \"$systemPrompt\""
### userPrompt
defaultUserPrompt="Who are you?"
read -p "Write a user prompt (default is '$defaultUserPrompt'): " userPrompt
if [[ -z "$userPrompt" ]]
then
    userPrompt=$defaultUserPrompt
fi
printf "$green" "UserPrompt: \"$userPrompt\""
### temperature
while true
do
    read -p "Define a temperature (real number between 0 and 1, default is 0.8): " temperature
    if [[ -z "$temperature" ]]
    then
        temperature=0.8
    fi
    if [[ "$temperature" =~ ^[0-9]+\.[0-9]+$ ]]
    then
        break
    else
        >&2 echo "Not a positive real number"
    fi
done
printf "$green" "Temperature: $temperature"
### seed
while true
do
    read -p "Define a seed (positive integer, default is 0): " seed
    if [[ -z "$seed" ]]
    then
        seed=0
    fi
    if [[ "$seed" =~ ^[0-9]+$ ]]
    then
        break
    else
        >&2 echo "Not a positive integer"
    fi
done
printf "$green" "Seed: $seed"
### request
systemMessage=$(jq -n \
    --arg content "$systemPrompt" \
    '{ role: "system", content: $content }')
userMessage=$(jq -n \
    --arg content "$userPrompt" \
    '{ role: "user", content: $content }')
messages=$(jq -n \
    --argjson sys "$systemMessage" \
    --argjson usr "$userMessage" \
    '[ $sys, $usr ]')
temperatureOption=$(jq -n \
    --arg value "$temperature" \
    '{ key: "temperature", value: $value }')
seedOption=$(jq -n \
    --arg value "$seed" \
    '{ key: "seed", value: $value }')
options=$(jq -n \
    --argjson temp "$temperatureOption" \
    --argjson seed "$seedOption" \
    '[ $temp, $seed ]')
request=$(jq -n \
    --arg model "$model" \
    --argjson maxCompletionTokens "$maxCompletionTokens" \
    --argjson messages "$messages" \
    --argjson options "$options" \
    '{
        model: $model,
        maxCompletionTokens: $maxCompletionTokens,
        messages: $messages,
        options: $options
    }')
cd contracts
CoprocessorCompleter=$(cat deployments/CoprocessorCompleter)
SimpleCallback=$(cat deployments/SimpleCallback)
mkdir -p requests
request_json_path=$(mktemp requests/XXXXXX.json)
echo "$request" > "$request_json_path"
completion_id_file_path=$(mktemp completionIds/XXXXXX)
sendSig='send(address,address,string,string)'
sendArgs=("$CoprocessorCompleter" "$SimpleCallback" "$request_json_path" "$completion_id_file_path")
forge script "$@" --quiet --broadcast SendScript --sig "$sendSig" "${sendArgs[@]}"
rm "$request_json_path"
echo "Completion requested!"
completion_id=$(cat $completion_id_file_path)
rm "$completion_id_file_path"
mkdir -p results
result_json_path=$(mktemp results/XXXXXX.json)
getResultSig='getResult(address,uint256,address,string)'
getResultArgs=("$SimpleCallback" "$completion_id" "$CoprocessorCompleter" "$result_json_path")
ts_start=$(date +%s)
while true
do
    forge script "$@" --quiet GetResultScript --sig "$getResultSig" "${getResultArgs[@]}"
    if [ -s $result_json_path ]
    then
        printf "\n"
        break
    else
        ts_now=$(date +%s)
        total_seconds=$(($ts_now - $ts_start))
        seconds=$(($total_seconds % 60))
        minutes=$(($total_seconds / 60))
        if [[ $minutes -eq 0 ]]
        then
            timedelta_str="$seconds second$([[ $seconds -eq 1 ]] || echo s)"
        else
            timedelta_str="$minutes minute$([[ $minutes -eq 1 ]] || echo s) and $seconds second$([[ $seconds -eq 1 ]] || echo s)"
        fi
        printf "\33[2K\r"
        printf "Awaiting result... ($timedelta_str)"
        sleep 5
    fi
done
result_json=$(cat $result_json_path)
rm "$result_json_path"
echo "Result received!"
echo "$result_json" | jq -r '.messages[] | "[" + .role + "] " + .content'
