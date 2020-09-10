import { combineReducers } from 'redux';

import BotReducer from './chatbot/reducers';
import HomeStateReducer from './home/reducers';
import { grantedPermissionsReducer } from './permissions/reducers';
import userReducer from './user/reducers';
import { UUIDReducer } from './uuid/reducers';

export default combineReducers({
  chatbot: BotReducer,
  home: HomeStateReducer,
  permissions: grantedPermissionsReducer,
  user: userReducer,
  uuid: UUIDReducer,
});
