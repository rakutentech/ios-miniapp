import { SET_CHATBOTS } from './types';
import type { SetChatBotsAction } from './types';

const getBotsList = (): SetChatBotsAction => {
  return {
    type: SET_CHATBOTS,
    payload: [
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
};

export { getBotsList };
