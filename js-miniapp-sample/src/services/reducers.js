import { combineReducers } from 'redux';

import MessageReducer from './message/reducers';
import HomeStateReducer from './home/reducers';
import { grantedPermissionsReducer } from './permissions/reducers';
import userReducer from './user/reducers';
import { UUIDReducer } from './uuid/reducers';
import { HostEnvironmentInfoReducer } from './landing/reducers';

export default combineReducers({
  message: MessageReducer,
  home: HomeStateReducer,
  permissions: grantedPermissionsReducer,
  user: userReducer,
  uuid: UUIDReducer,
  info: HostEnvironmentInfoReducer,
});
