import { Container, Title, Text, Button, Space, Group, Grid } from '@mantine/core';
import { Link } from 'react-router-dom';
import { IconMessageFilled } from '@tabler/icons-react';
import { Card, Badge } from '@mantine/core';
import { TRENDING_MODELS, CATEGORY_COLORS } from '../types/types';

export function Home() {
  const chatIcon = <IconMessageFilled size={22} />;

  const trendingModels = TRENDING_MODELS.map((item) => (
    <Grid.Col span={6}>
      <Card shadow="sm" padding="lg" radius="md" withBorder h={150}>
        <Text fw={500}>{item.name}</Text>
        <Badge color={CATEGORY_COLORS[item.category]}>{item.category}</Badge>
        <Text size="sm" c="dimmed" py="xs">{item.description}</Text>
      </Card>
    </Grid.Col>
  ));

  return (
    <Container>
      <Container mt={20} mb={20}>
        <Title ta="center">Onchain Verifiable LLM service</Title>
        <Space h="md" />
        <Text size="lg" c="dimmed" ta="center">
          Use with EVM <b>smart contracts</b>, pay <b>by token</b>, choose <b>any open model</b>
        </Text>
        <Space h="xl" />
        <Group justify="center">
          <Button component={Link} to="/chat" size="lg" rightSection={chatIcon}>Chat</Button>
          <Button component={Link} to="/models" size="lg" variant="default">Browse</Button>
        </Group>
      </Container>

      <Text size="md" c="dimmed" mb={8} ta="center">TRENDING MODELS</Text>
      <Grid>{trendingModels}</Grid>
    </Container>
  );
}