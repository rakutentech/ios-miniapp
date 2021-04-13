import type { MessageType, SetMessageTypeAction } from './types';
import { SET_MESSAGE_TYPES } from './types';

type MessageTypeState = {
  messageTypes: Array<MessageType>,
};

const messageTypeState = {
  messageTypes: [
    {
      id: 1,
      name: 'Send a message to a single contact',
    },
    {
      id: 2,
      name: 'Send a message to a specific contact',
    },
    {
      id: 3,
      name: 'Send a message to multiple contacts',
    },
  ],
};

export default (state: MessageTypeState, action: SetMessageTypeAction) => {
  if (action.type === SET_MESSAGE_TYPES) {
    return { ...state, messageTypes: action.payload };
  }
  return messageTypeState;
};
