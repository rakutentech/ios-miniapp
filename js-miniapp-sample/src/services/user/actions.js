import MiniApp from 'js-miniapp-sdk';

import {
  REQUEST_USER_NAME_SUCCESS,
  REQUEST_USER_NAME_FAILURE,
  REQUEST_PROFILE_PHOTO_SUCCESS,
  REQUEST_PROFILE_PHOTO_FAILURE,
  REQUEST_CONTACT_LIST_SUCCESS,
  REQUEST_CONTACT_LIST_FAILURE,
} from './types';

import { Contact } from 'js-miniapp-sdk';

type UserNameSuccessAction = { type: String, userName: string };
type ProfilePhotoSuccessAction = { type: String, url: string };
type ContactListSuccessAction = { type: String, contacts: Contact[] };

const requestUserName = (): Function => {
  return (dispatch) => {
    return MiniApp.user
      .getUserName()
      .then((userName) => {
        dispatch({
          type: REQUEST_USER_NAME_SUCCESS,
          userName,
        });
      })
      .catch((_) => {
        dispatch({
          type: REQUEST_USER_NAME_FAILURE,
        });
      });
  };
};

const requestProfilePhoto = (): Function => {
  return (dispatch) => {
    return MiniApp.user
      .getProfilePhoto()
      .then((url) => {
        dispatch({
          type: REQUEST_PROFILE_PHOTO_SUCCESS,
          url,
        });
      })
      .catch((_) => {
        dispatch({
          type: REQUEST_PROFILE_PHOTO_FAILURE,
        });
      });
  };
};

const requestContactList = (): Function => {
  return (dispatch) => {
    return MiniApp.user
      .getContacts()
      .then((contacts) => {
        dispatch({
          type: REQUEST_CONTACT_LIST_SUCCESS,
          contacts,
        });

        return Promise.resolve(contacts);
      })
      .catch((_) => {
        dispatch({
          type: REQUEST_CONTACT_LIST_FAILURE,
        });
      });
  };
};

export { requestUserName, requestProfilePhoto, requestContactList };
export type {
  UserNameSuccessAction,
  ProfilePhotoSuccessAction,
  ContactListSuccessAction,
};
