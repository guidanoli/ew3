import { Container, Title, Grid, Text, Button, Badge, Divider, Group } from '@mantine/core';
import { MODELS, CATEGORY_COLORS } from '../types/types';
import { Link } from 'react-router-dom';
import { IconMessageFilled } from '@tabler/icons-react';

export function Models() {
  const chatIcon = <IconMessageFilled size={18} />;

  return (
    <Container>
      <Title order={1} mx="md">Models</Title>
      <Grid mt="xl">
        {MODELS.map((model) => (
          <Grid.Col key={model.id} span={12}>
            <Container>
              <Group justify="space-between">
                <Title order={3}>{model.name}</Title>
                <Button component={Link} to="/chat" rightSection={chatIcon}>Chat</Button>
              </Group>
              <Badge color={CATEGORY_COLORS[model.category]}>{model.category}</Badge>
              <Text mt="md" c="dimmed">{model.description}</Text>
              <Group mt="sm" c="dimmed">
                <Text size="sm">{(model.contextLength/1024).toLocaleString()}K context</Text>
                <Divider size="sm" orientation="vertical" />
                <Text size="sm">ETH {model.pricePerInputToken.toFixed(4)}/input token</Text>
                <Divider size="sm" orientation="vertical" />
                <Text size="sm">ETH {model.pricePerOutputToken.toFixed(4)}/output token</Text>
              </Group>
              <Divider mt="lg"/>
            </Container>
          </Grid.Col>
        ))}
      </Grid>
    </Container>
  );
}