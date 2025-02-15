/**
 * Decode the receipt to extract the completionId
 */
import { toEventHash, parseAbi, parseAbiParameters, decodeAbiParameters, decodeEventLog } from 'viem'
import { WaitForTransactionReceiptReturnType } from '@wagmi/core'

const eventAbi = parseAbi(['event TaskIssued(bytes32,bytes,address)'])
const eventHash = toEventHash(eventAbi[0])

const coprocessorInputParameters = parseAbiParameters(
    'uint256 completionId, string modelName, uint256 maxCompletionTokens, (string content, string role)[] messages, (string key, string value)[] options, address callbackContractAddress'
)

export function getCompletionIdFromReceipt(receipt: WaitForTransactionReceiptReturnType): bigint {

    const event = receipt.logs.find(log => log.topics[0] === eventHash)
    if (!event) {
        throw new Error('TaskIssued event not found')
    }

    const decodedEvent = decodeEventLog({
        abi: eventAbi,
        data: event.data,
        topics: [eventHash],
    })

    if (!decodedEvent.args) {
        throw new Error('TaskIssued event args not found')
    }

    const coprocessorInput = decodeAbiParameters(coprocessorInputParameters, decodedEvent.args[1])

    return coprocessorInput[0] as bigint;
}
