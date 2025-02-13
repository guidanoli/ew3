import { useState } from 'react';
import { Container, Title, Select, Textarea, Button, Paper, Stack } from '@mantine/core';
import { Message } from '../types/types';
import { MODELS } from '../types/types';

export function Chat() {
  const [selectedModel, setSelectedModel] = useState<string | null>(null);
  const [input, setInput] = useState('');
  const [messages, setMessages] = useState<Message[]>([]);

  const handleSubmit = () => {
    if (!input.trim()) return;

    const userMessage: Message = {
      role: 'user',
      content: input,
      timestamp: new Date(),
    };

    const mockResponse: Message = {
      role: 'assistant',
      content: `Mock response from ${selectedModel}`,
      timestamp: new Date(),
    };

    setMessages([...messages, userMessage, mockResponse]);
    setInput('');
  };

  return (
    <Container>
      <Title order={1}>Chat</Title>
      <Select
        label="Select Model"
        placeholder="Choose a model"
        data={MODELS.map(model => ({ value: model.id, label: model.name }))}
        value={selectedModel}
        onChange={setSelectedModel}
        mb="md"
      />
      <Stack gap="md">
        {messages.map((message, index) => (
          <Paper
            key={index}
            p="md"
            style={{
              backgroundColor: message.role === 'user' ? '#f8f9fa' : '#e9ecef',
              marginLeft: message.role === 'user' ? 'auto' : 0,
              marginRight: message.role === 'assistant' ? 'auto' : 0,
              maxWidth: '80%',
            }}
          >
            {message.content}
          </Paper>
        ))}
      </Stack>
      <Textarea
        placeholder="Type your message..."
        value={input}
        onChange={(e) => setInput(e.currentTarget.value)}
        minRows={1}
        mt="xl"
      />
      <Button
        onClick={handleSubmit}
        disabled={!selectedModel || !input.trim()}
        mt="md"
      >
        Send
      </Button>
    </Container>
  );
}