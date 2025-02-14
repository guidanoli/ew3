export interface Model {
  id: string;
  name: string;
  category: string;
  pricePerInputToken: number;
  pricePerOutputToken: number;
  description: string;
  contextLength: number;
}

export interface Message {
  role: 'user' | 'assistant';
  content: string;
  timestamp: Date;
}

const BASE_PRICE_ETH = 0.0004;

export const MODELS: Model[] = [
  {
    id: 'SmolLM2-135M-Instruct',
    name: 'SmolLM2 135M Instruct',
    category: 'General',
    pricePerInputToken: BASE_PRICE_ETH,
    pricePerOutputToken: BASE_PRICE_ETH*2,
    description: 'Tiniest model for general tasks, very fast and cheap.',
    contextLength: 8192,
  },
  {
    id: 'SmolLM2-360M-Instruct',
    name: 'SmolLM2 360M Instruct',
    category: 'General',
    pricePerInputToken: BASE_PRICE_ETH*2,
    pricePerOutputToken: BASE_PRICE_ETH*4,
    description: 'Tiny general model, fast and cheap.',
    contextLength: 8192,
  },
  {
    id: 'Qwen2.5-0.5B-Instruct',
    name: 'Qwen2.5 0.5B Instruct',
    category: 'General',
    pricePerInputToken: BASE_PRICE_ETH*4,
    pricePerOutputToken: BASE_PRICE_ETH*4*2,
    description: 'Small model for general tasks.',
    contextLength: 32768,
  },
  {
    id: 'Qwen2.5-Coder-0.5B-Instruct',
    name: 'Qwen2.5 Coder 0.5B Instruct',
    category: 'Programming',
    pricePerInputToken: BASE_PRICE_ETH*4,
    pricePerOutputToken: BASE_PRICE_ETH*4*2,
    description: 'Small model specialized in programming tasks.',
    contextLength: 32768,
  },
  {
    id: 'Qwen2.5-1.5B-Instruct',
    name: 'Qwen2.5 1.5B Instruct',
    category: 'General',
    pricePerInputToken: BASE_PRICE_ETH*12,
    pricePerOutputToken: BASE_PRICE_ETH*12*2,
    description: 'Medium model for general tasks.',
    contextLength: 32768,
  },
  {
    id: 'Qwen2.5-Coder-1.5B-Instruct',
    name: 'Qwen2.5 Coder 1.5B Instruct',
    category: 'Programming',
    pricePerInputToken: BASE_PRICE_ETH*12,
    pricePerOutputToken: BASE_PRICE_ETH*12*2,
    description: 'Medium model specialized in programming tasks.',
    contextLength: 32768,
  },
  {
    id: 'Qwen2.5-Math-1.5B-Instruct',
    name: 'Qwen2.5 Math 1.5B Instruct',
    category: 'Math',
    pricePerInputToken: BASE_PRICE_ETH*12,
    pricePerOutputToken: BASE_PRICE_ETH*12*2,
    description: 'Medium model specialized in math tasks.',
    contextLength: 4096,
  },
  {
    id: 'SmolLM2-1.7B-Instruct',
    name: 'SmolLM2 1.7B Instruct',
    category: 'General',
    pricePerInputToken: BASE_PRICE_ETH*16,
    pricePerOutputToken: BASE_PRICE_ETH*16*2,
    description: 'Medium model for general tasks.',
    contextLength: 8192,
  },
  {
    id: 'DeepSeek-R1-Distill-Qwen-1.5B',
    name: 'DeepSeek R1 Distill Qwen 1.5B',
    category: 'Reasoning',
    pricePerInputToken: BASE_PRICE_ETH*20,
    pricePerOutputToken: BASE_PRICE_ETH*20*2,
    description: 'Medium model specialized in tasks that requires advanced reasoning.',
    contextLength: 65536,
  },
  {
    id: 'DeepScaleR-1.5B-Preview',
    name: 'DeepScaleR 1.5B Preview',
    category: 'Reasoning',
    pricePerInputToken: BASE_PRICE_ETH*20,
    pricePerOutputToken: BASE_PRICE_ETH*20*2,
    description: 'Most intelligent model specialized in tasks that requires advanced reasoning.',
    contextLength: 65536,
  },
];

export const TRENDING_MODELS = [
  {
    name: 'SmolLM2 135M Instruct',
    category: "General",
    description: "Tiniest model for general tasks, very fast and cheap."
  },
  {
    name: 'DeepScaleR 1.5B Preview',
    category: "Reasoning",
    description: "Most intelligent model specialized in tasks that requires advanced reasoning."
  },
  {
    name: 'Qwen2.5 Coder 1.5B Instruct',
    category: "Programming",
    description: "Medium model specialized in programming tasks."
  },
  {
    name: 'Qwen2.5 Math 1.5B Instruct',
    category: "Math",
    description: "Medium model specialized in math tasks."
  },
];

export const CATEGORY_COLORS: any = {
  General: "blue",
  Reasoning: "pink",
  Programming: "orange",
  Math: "green",
}
