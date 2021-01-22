import { Contact, AccessTokenData } from '../../../js-miniapp-bridge/src';
import { getBridge } from '../utils';

/**
 * Interfaces to retrieve User profile related information.
 */
export interface UserInfoProvider {
  /**
   * Fetches the username from host app.
   * You should request the {@link CustomPermissionName.USER_NAME} permission before using this method.
   * @returns Username saved in the host app user profile.
   */
  getUserName(): Promise<string>;

  /**
   * Fetches the profile photo URI from host app.
   * You should request the {@link CustomPermissionName.PROFILE_PHOTO} permission before using this method.
   * @returns Profile photo saved in the host app user profile.
   */
  getProfilePhoto(): Promise<string>;

  /**
   * Fetches the contact list from host app.
   * You should request the {@link CustomPermissionName.CONTACT_LIST} permission before using this method.
   * @returns Contact list in the host app user profile.
   */
  getContacts(): Promise<Contact[]>;

  /**
   * Fetches the access token from host app.
   * @returns Access token from native host app.
   */
  getAccessToken(): Promise<AccessTokenData>;
}

/** @internal */
export class UserInfo implements UserInfoProvider {
  getUserName(): Promise<string> {
    return getBridge().getUserName();
  }

  getProfilePhoto(): Promise<string> {
    return getBridge().getProfilePhoto();
  }

  getContacts(): Promise<Contact[]> {
    return getBridge().getContacts();
  }

  getAccessToken(): Promise<AccessTokenData> {
    return getBridge().getAccessToken();
  }
}
