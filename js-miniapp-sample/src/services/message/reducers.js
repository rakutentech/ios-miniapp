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
  ],
};

export default (
  state: MessageTypeState,
  action: SetMessageTypeAction
) => {
  if (action.type === SET_MESSAGE_TYPES) {
    return { ...state, messageTypes: action.payload };
  }
  return messageTypeState;
};
