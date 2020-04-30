const SET_CHATBOTS = 'GET_CHATBOTS';

type ChatBot = {
  id: number,
  name: string,
};

type SetChatBotsAction = {
  type: string,
  payload: Array<ChatBot>,
};

type ChatBotAction = SetChatBotsAction;

export { SET_CHATBOTS };
export type { ChatBot, SetChatBotsAction, ChatBotAction };
