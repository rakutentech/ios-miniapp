import type { ChatBot, ChatBotAction } from './types';
import { SET_CHATBOTS } from './types';

type ChatBotState = {
  bots: Array<ChatBot>,
};

const chatbotState = {
  bots: [
    {
      id: 1,
      name: 'R-Chatbot',
    },
    {
      id: 2,
      name: 'M-Chatbot',
    },
    {
      id: 3,
      name: 'K-Chatbot',
    },
  ],
};

export default (state: ChatBotState = chatbotState, action: ChatBotAction) => {
  if (action.type === SET_CHATBOTS) {
    return { ...state, bots: action.payload };
  }
  return state;
};
