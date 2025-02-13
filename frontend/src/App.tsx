// Import styles of packages that you've installed.
// All packages except `@mantine/hooks` require styles imports
import '@mantine/core/styles.css';
import '@rainbow-me/rainbowkit/styles.css';

import { MantineProvider, createTheme, AppShell, Burger, Group, Center, Button, Text } from '@mantine/core';
import { useDisclosure } from '@mantine/hooks';
import { BrowserRouter, Routes, Route, Link } from 'react-router-dom';
import { Home } from './pages/Home';
import { Models } from './pages/Models';
import { Chat } from './pages/Chat';
import { IconBrain, IconBrandGithub } from '@tabler/icons-react';
import { ConnectButton } from '@rainbow-me/rainbowkit';
import { getDefaultConfig, RainbowKitProvider, Chain } from '@rainbow-me/rainbowkit';
import { WagmiProvider } from 'wagmi';
import { mainnet } from 'wagmi/chains';
import { QueryClientProvider, QueryClient } from "@tanstack/react-query";

/*
const devnet = {
  id: 43_114,
  name: 'Avalanche',
  iconUrl: 'https://s2.coinmarketcap.com/static/img/coins/64x64/5805.png',
  iconBackground: '#fff',
  nativeCurrency: { name: 'Avalanche', symbol: 'AVAX', decimals: 18 },
  rpcUrls: {
    default: { http: ['https://api.avax.network/ext/bc/C/rpc'] },
  },
  blockExplorers: {
    default: { name: 'SnowTrace', url: 'https://snowtrace.io' },
  },
  contracts: {
    multicall3: {
      address: '0xca11bde05977b3631167028862be2a173976ca11',
      blockCreated: 11_907_934,
    },
  },
} as const satisfies Chain;
*/

const config = getDefaultConfig({
  appName: 'ThinkChain',
  projectId: 'YOUR_PROJECT_ID',
  chains: [mainnet],
  ssr: false, // If your dApp uses server side rendering (SSR)
});
const queryClient = new QueryClient();

const theme = createTheme({});

export default function App() {
  const [opened, { toggle }] = useDisclosure();

  return (
    <WagmiProvider config={config}>
      <QueryClientProvider client={queryClient}>
        <RainbowKitProvider>
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
                      <Group ml="xl" gap="sm" visibleFrom="sm">
                        <Button component={Link} to="/models" variant="default">Models</Button>
                        <Button component={Link} to="/chat" variant="default">Chat</Button>
                        <ConnectButton/>
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
        </RainbowKitProvider>
      </QueryClientProvider>
    </WagmiProvider>
  );
}