import { combineReducers } from 'redux';

import BotReducer from './chatbot/reducers';
import HomeStateReducer from './home/reducers';
import { UUIDReducer } from './uuid/reducers';

export default combineReducers({
  home: HomeStateReducer,
  uuid: UUIDReducer,
  chatbot: BotReducer,
});
