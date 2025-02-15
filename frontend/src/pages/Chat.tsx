import { useState } from 'react';
import { Container, Title, Select, Textarea, Button, Paper, Stack, Text, Loader, Group, NumberInput, Slider, Grid, Divider} from '@mantine/core';
import { Message } from '../types/types';
import { MODELS } from '../types/types';
import { Request, Message as ABIMessage, Option, ABI_COMPLETER, ABI_SIMPLE_CALLBACK } from '../types/ABIs';
import { readContract, waitForTransactionReceipt, watchContractEvent } from '@wagmi/core';
import { config } from '../wagmiConfig';
import { useWriteContract } from 'wagmi';
import { getCompletionIdFromReceipt } from '../types/receipt';

export function Chat() {
  const [selectedModel, setSelectedModel] = useState<string | null>(null);
  const [maxCompletionTokens, setMaxCompletionTokens] = useState(100);
  const [temperature, setTemperature] = useState(0.8);
  const [input, setInput] = useState('');
  const [messages, setMessages] = useState<Message[]>([]);
  const {writeContractAsync} = useWriteContract();

  const [outgoingMessage, setOutgoingMessage] = useState<Message | null>(null);
  const [completionId, setCompletionId] = useState<bigint | null>(null);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    if (!input.trim() || !selectedModel) return;

    if (completionId) {
      console.log("There is a completion already running, please wait for it to finish")
      return;
    }

    // Assemble the request
    const userMessage: Message = {
      role: 'user',
      content: input,
      timestamp: new Date(),
    };

    setOutgoingMessage(userMessage);
    setInput('');

    const requestMessages = messages.map(message => ({
      role: message.role,
      content: message.content,
    })) as ABIMessage[];

    requestMessages.push({
      role: 'user',
      content: input,
    });

    const request: Request = {
      maxCompletionTokens: maxCompletionTokens,
      messages: requestMessages,
      model: selectedModel,
      options: [{key: 'temperature', value: temperature.toString()} as Option],
    };

    const requestCost = await readContract(config, {
      address: import.meta.env.VITE_COMPLETION_CONTRACT_ADDRESS,
      abi: ABI_COMPLETER,
      functionName: 'getCompletionRequestCost',
      args: [request],
    });
    
    console.log("Cost: ", requestCost);

    if (typeof requestCost === 'undefined') {
      throw new Error("Request cost is undefined");
    }

    const txHash = await writeContractAsync({
      address: import.meta.env.VITE_COMPLETION_CONTRACT_ADDRESS,
      abi: ABI_COMPLETER,
      functionName: 'requestCompletion',
      args: [request, import.meta.env.VITE_CALLBACK_CONTRACT_ADDRESS],
      value: requestCost as bigint,
    });
    console.log("Transaction hash: ", txHash)

    const tx = await waitForTransactionReceipt(config, {hash: txHash});
    console.log("Transaction receipt: ", tx)

    const _completionId = getCompletionIdFromReceipt(tx)
    console.log("Completion ID: ", _completionId)

    setCompletionId(_completionId);
    setMessages([...messages, userMessage]);
    setOutgoingMessage(null);

    const unwatch = watchContractEvent(config, {
      address: import.meta.env.VITE_CALLBACK_CONTRACT_ADDRESS,
      abi: ABI_SIMPLE_CALLBACK,
      eventName: 'ResultReceived',
      poll: true,
      onLogs: (logs) => {
        console.log("Completion notice: ", logs)
        for (const log of logs) {
          if (log.args.completionId != _completionId) continue;

          for (const msg of log.args.messages) {
            const responseMessage = {
              role: msg.role as 'user' | 'assistant',
              content: msg.content,
              timestamp: new Date(),
            };

            setMessages([...messages, userMessage, responseMessage]);
          }

          setCompletionId(null);
          unwatch();
        }
      },
      onError: (error: Error) => {
        console.error("Error watching contract event: ", error)
      }
    })
  };

  return (
    <Container>
      <Title order={1}>Chat</Title>
      <Grid my="lg">
        <Grid.Col span={{base: 12, sm: 6}}>
          <Select
            label="Model"
            placeholder="Choose a model"
            data={MODELS.map(model => ({ value: model.id, label: model.name }))}
            value={selectedModel}
            onChange={setSelectedModel}
          />
        </Grid.Col>
        <Grid.Col span={{base: 12, sm: 3}}>
          <NumberInput
          label="Max Tokens"
            value={maxCompletionTokens}
            onChange={(value) => setMaxCompletionTokens(Number(value))}
            min={1}
            max={511}
            allowDecimal={false}
          />
        </Grid.Col>
        <Grid.Col span={{base: 12, sm: 3}}>
          <Text size="sm" fw={500}>Temperature</Text>
          <Slider
          value={temperature}
          onChange={setTemperature}
          min={0.5}
          max={1}
          step={0.1}
          marks={[
            {value: 0.5, label: '0.5'},
            {value: 0.6, label: '0.6'},
            {value: 0.7, label: '0.7'},
            {value: 0.8, label: '0.8'},
            {value: 0.9, label: '0.9'},
            {value: 1, label: '1'},
          ]}
          />
        </Grid.Col>
      </Grid>
      <Divider my="xl" />
      <Stack gap="md">
        {messages.map((message, index) => (
          <Paper
            key={index}
            p="md"
            radius="lg"
            withBorder
            style={{
              backgroundColor: message.role === 'user' ? '#f8f9fa' : 'var(--mantine-color-blue-light)',
              marginLeft: message.role === 'user' ? 'auto' : 0,
              marginRight: message.role === 'assistant' ? 'auto' : 0,
              maxWidth: '80%',
            }}
          >
            <Text>{message.content}</Text>
            <Text size="xs" mt="sm" c="gray" ta={message.role === 'user' ? 'right' : 'left'}>{message.timestamp.toLocaleTimeString()}</Text>
          </Paper>
        ))}
        {outgoingMessage && (
          <Paper p="md" radius="lg" withBorder style={{
            backgroundColor: '#f8f9fa',
            marginLeft: 'auto',
            marginRight: 0,
          }}
          >
            <Text>{outgoingMessage.content}</Text>
            <Text size="xs" mt="sm" c="gray" ta="right">Waiting for confirmation...</Text>
          </Paper>
        )}
        {completionId && (
          <Paper p="md" radius="lg" withBorder style={{
            backgroundColor: 'var(--mantine-color-blue-light)',
            marginLeft: 0,
            marginRight: 'auto',
          }}
          >
            <Group justify="center">
              <Loader color="blue" type="dots" variant="light" />
            </Group>
            <Text size="xs" mt="sm" c="gray" ta="right">Waiting for completion {completionId}</Text>
          </Paper>
        )}
      </Stack>
      <form onSubmit={handleSubmit}>
        <Textarea
          placeholder="Type your message..."
          value={input}
          onChange={(e) => setInput(e.currentTarget.value)}
          minRows={1}
          mt="xl"
          disabled={!!completionId}
        />
        <Button
          type="submit"
          disabled={!selectedModel || !input.trim() || !!completionId}
          mt="md"
        >
          Send
        </Button>
      </form>
    </Container>
  );
}