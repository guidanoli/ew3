// Import styles of packages that you've installed.
// All packages except `@mantine/hooks` require styles imports
import '@mantine/core/styles.css';

import { MantineProvider, createTheme, AppShell, Burger, Group, Center, Button, Text } from '@mantine/core';
import { useDisclosure } from '@mantine/hooks';
import { BrowserRouter, Routes, Route, Link } from 'react-router-dom';
import { Home } from './pages/Home';
import { Models } from './pages/Models';
import { Chat } from './pages/Chat';
import { IconBrain, IconBrandGithub } from '@tabler/icons-react';

const theme = createTheme({});

export default function App() {
  const [opened, { toggle }] = useDisclosure();

  return (
    <MantineProvider theme={theme}>
      <BrowserRouter>
        <AppShell
          header={{ height: 60 }}
          navbar={{ width: 300, breakpoint: 'sm', collapsed: { desktop: true, mobile: !opened } }}
          padding="md"
        >
          <AppShell.Header>
            <Group h="100%" px="md">
              <Burger opened={opened} onClick={toggle} hiddenFrom="sm" size="sm" />
              <Group justify="space-between" style={{ flex: 1 }}>
                <Button component={Link} to="/" variant="subtle"><IconBrain/>ThinkChain</Button>
                <Group ml="xl" gap={2} visibleFrom="sm">
                  <Button component={Link} to="/models" variant="default">Models</Button>
                  <Button component={Link} to="/chat" variant="default">Chat</Button>
                </Group>
              </Group>
            </Group>
          </AppShell.Header>

          <AppShell.Navbar py="md" px={4}>
            <Button component={Link} to="/" variant="subtle">LLM Router</Button>
            <Button component={Link} to="/models" variant="subtle">Models</Button>
            <Button component={Link} to="/chat" variant="subtle">Chat</Button>
          </AppShell.Navbar>

          <AppShell.Main>
            <Routes>
              <Route path="/" element={<Home />} />
              <Route path="/models" element={<Models />} />
              <Route path="/chat" element={<Chat />} />
            </Routes>
            <Center>
              <Text py="md" size="lg" mr="xs" c="dimmed">©2025 ThinkChain</Text>
              <Button component="a" color="gray" variant="subtle" px="xs" href="https://github.com/guidanoli/ew3"><IconBrandGithub/></Button>
            </Center>
          </AppShell.Main>
        </AppShell>
      </BrowserRouter>
    </MantineProvider>
  );
}