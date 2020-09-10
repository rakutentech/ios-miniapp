import { combineReducers } from 'redux';

import type {
  UserNameSuccessAction,
  ProfilePhotoSuccessAction,
  ContactListSuccessAction,
} from './actions';
import {
  REQUEST_CONTACT_LIST_SUCCESS,
  REQUEST_USER_NAME_SUCCESS,
  REQUEST_PROFILE_PHOTO_SUCCESS,
} from './types';

const defaultUserName = null;
const userNameReducer = (
  state: ?string = defaultUserName,
  action: UserNameSuccessAction
): ?string => {
  switch (action.type) {
    case REQUEST_USER_NAME_SUCCESS:
      return action.userName;
    default:
      return state;
  }
};

const defaultProfilePhoto = null;
const profilePhotoReducer = (
  state: ?string = defaultProfilePhoto,
  action: ProfilePhotoSuccessAction
): ?string => {
  switch (action.type) {
    case REQUEST_PROFILE_PHOTO_SUCCESS:
      return action.url;
    default:
      return state;
  }
};

const defaultContactList = null;
const contactListReducer = (
  state: ?(string[]) = defaultContactList,
  action: ContactListSuccessAction
): ?(string[]) => {
  switch (action.type) {
    case REQUEST_CONTACT_LIST_SUCCESS:
      return action.contacts;
    default:
      return state;
  }
};

export default combineReducers({
  userName: userNameReducer,
  profilePhoto: profilePhotoReducer,
  contactList: contactListReducer,
});
