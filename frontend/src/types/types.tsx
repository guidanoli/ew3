export interface Model {
  id: string;
  name: string;
  color: string;
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

export const MODELS: Model[] = [
  {
    id: 'SmolLM2-360M-Instruct',
    name: 'SmolLM2 360M Instruct',
    category: 'General',
    color: "blue",
    pricePerInputToken: 0.00003,
    pricePerOutputToken: 0.00006,
    description: 'Our most lightweight model, fast and cheap.',
    contextLength: 8192,
  },
  {
    id: 'DeepSeek-R1-Distill-Qwen-1.5B',
    name: 'DeepSeek R1 Distill Qwen 1.5B',
    category: 'Reasoning',
    color: "pink",
    pricePerInputToken: 0.00002,
    pricePerOutputToken: 0.00004,
    description: 'Our most intelligent model, with advanced reasoning and analysis.',
    contextLength: 65536,
  },
];

export const TRENDING_MODELS = [
  {
    name: 'SmolLM2 360M Instruct',
    category: "General",
    color: "blue",
    description: "Our most lightweight model, fast and cheap."
  },
  {
    name: 'DeepScaleR 1.5B Preview',
    category: "Reasoning",
    color: "pink",
    description: "Our most intelligent model, with advanced reasoning and analysis."
  },
  {
    name: 'Qwen2.5 Coder 1.5B Instruct',
    category: "Programming",
    color: "orange",
    description: "Our best model for programming tasks."
  },
];
