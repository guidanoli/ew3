import { getDefaultConfig } from '@rainbow-me/rainbowkit';
import { metaMaskWallet, rainbowWallet } from '@rainbow-me/rainbowkit/wallets';
import { anvil } from 'viem/chains';


export const config = getDefaultConfig({
  appName: 'ThinkChain',
  projectId: import.meta.env.VITE_WALLET_CONNECT_PROJECT_ID,
  chains: [anvil],
  wallets: [{
      groupName: 'Popular',
      wallets:[
      metaMaskWallet,
      rainbowWallet,
    ],
  }],
  ssr: false, // If your dApp uses server side rendering (SSR)
});