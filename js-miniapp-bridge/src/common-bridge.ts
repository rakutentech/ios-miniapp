/** @internal */

/**
 * Bridge for communicating with Mini App
 */

import { AdTypes } from './types/ad-types';
import { Reward } from './types/response-types/rewarded';
import { DevicePermission } from './types/device-permission';
import {
  CustomPermission,
  CustomPermissionResponse,
} from './types/custom-permissions';
import { ShareInfoType } from './types/share-info';
import { ScreenOrientation } from './types/screen';
import { NativeTokenData, AccessTokenData } from './types/token-data';
import { Contact } from './types/contact';
import { MessageToContact } from './types/message-to-contact';

/** @internal */
const mabMessageQueue: Callback[] = [];
export { mabMessageQueue };

/** @internal */
export interface Callback {
  id: string;
  onSuccess: (value: string) => void;
  onError: (error: string) => void;
}

/** @internal */
export interface PlatformExecutor {
  /**
   * Method to call the native interface methods for respective platforms
   * such as iOS & Android.
   * @param  {[string]} action Action command/interface name that native side need to execute
   * @param  {Object} param Object that contains request parameter values like permissions.
   * For eg., {permission: 'location'}
   * @param  {[Function]} onSuccess Success callback function
   * @param  {[Function]} onError Error callback function
   */
  exec(
    action: string,
    param: object | null,
    onSuccess: (value: string) => void,
    onError: (error: string) => void
  ): void;

  /**
   * Get the platform which injects this bridge.
   * @returns The platform name. It could be 'Android' or 'iOS'.
   */
  getPlatform(): string;
}

/** @internal */
export class MiniAppBridge {
  executor: PlatformExecutor;
  platform: string;

  constructor(executor: PlatformExecutor) {
    this.executor = executor;
    this.platform = executor.getPlatform();
  }

  /**
   * Success Callback method that will be called from native side
   * to this bridge. This method will send back the value to the
   * mini apps that uses promises.
   * @param  {[String]} messageId Message ID which will be used to get callback object from messageQueue
   * @param  {[String]} value Response value sent from the native on invoking the action command
   */
  execSuccessCallback(messageId, value) {
    const queueObj = mabMessageQueue.filter(
      callback => callback.id === messageId
    )[0];
    if (value) {
      queueObj.onSuccess(value);
    } else {
      queueObj.onError('Unknown Error');
    }
    removeFromMessageQueue(queueObj);
  }

  /**
   * Error Callback method that will be called from native side
   * to this bridge. This method will send back the error message to the
   * mini apps that uses promises.
   * @param  {[String]} messageId Message ID which will be used to get callback object from messageQueue
   * @param  {[String]} errorMessage Error message sent from the native on invoking the action command
   */
  execErrorCallback(messageId, errorMessage) {
    const queueObj = mabMessageQueue.filter(
      callback => callback.id === messageId
    )[0];
    if (!errorMessage) {
      errorMessage = 'Unknown Error';
    }
    queueObj.onError(errorMessage);
    removeFromMessageQueue(queueObj);
  }

  /**
   * Associating getUniqueId function to MiniAppBridge object.
   */
  getUniqueId() {
    return new Promise<string>((resolve, reject) => {
      return this.executor.exec(
        'getUniqueId',
        null,
        id => resolve(id),
        error => reject(error)
      );
    });
  }

  /**
   * Associating requestPermission function to MiniAppBridge object.
   * @param {DevicePermission} permissionType Type of permission that is requested e.g. location
   */
  requestPermission(permissionType: DevicePermission) {
    return new Promise<string>((resolve, reject) => {
      return this.executor.exec(
        'requestPermission',
        { permission: permissionType },
        success => resolve(success),
        error => reject(error)
      );
    });
  }

  /**
   * Associating showInterstitialAd function to MiniAppBridge object.
   * @param {string} id ad unit id of the intertitial ad
   */
  showInterstitialAd(id: string) {
    return new Promise<string>((resolve, reject) => {
      return this.executor.exec(
        'showAd',
        { adType: AdTypes.INTERSTITIAL, adUnitId: id },
        closeSuccess => resolve(closeSuccess),
        error => reject(error)
      );
    });
  }

  /**
   * Associating loadInterstitialAd function to MiniAppBridge object.
   * This function preloads interstitial ad before they are requested for display.
   * Can be called multiple times to pre-load multiple ads.
   * @param {string} id ad unit id of the interstitial ad that needs to be loaded.
   */
  loadInterstitialAd(id: string) {
    return new Promise<string>((resolve, reject) => {
      return this.executor.exec(
        'loadAd',
        { adType: AdTypes.INTERSTITIAL, adUnitId: id },
        loadSuccess => resolve(loadSuccess),
        error => reject(error)
      );
    });
  }

  /**
   * Associating loadRewardedAd function to MiniAppBridge object.
   * This function preloads Rewarded ad before they are requested for display.
   * Can be called multiple times to pre-load multiple ads.
   * @param {string} id ad unit id of the Rewarded ad that needs to be loaded.
   */
  loadRewardedAd(id: string) {
    return new Promise<string>((resolve, reject) => {
      return this.executor.exec(
        'loadAd',
        { adType: AdTypes.REWARDED, adUnitId: id },
        loadSuccess => resolve(loadSuccess),
        error => reject(error)
      );
    });
  }

  /**
   * Associating showRewardedAd function to MiniAppBridge object.
   * @param {string} id ad unit id of the Rewarded ad
   */
  showRewardedAd(id: string) {
    return new Promise<Reward>((resolve, reject) => {
      return this.executor.exec(
        'showAd',
        { adType: AdTypes.REWARDED, adUnitId: id },
        rewardResponse => resolve(JSON.parse(rewardResponse) as Reward),
        error => reject(error)
      );
    });
  }

  /**
   * Associating requestCustomPermissions function to MiniAppBridge object
   * @param [CustomPermissionType[] permissionTypes, Types of custom permissions that are requested
   * using an Array including the parameters eg. name, description.
   *
   * For eg., Miniapps can pass the array of valid custom permissions as following
   * [
   *  {"name":"rakuten.miniapp.user.USER_NAME", "description": "Reason to request for the custom permission"},
   *  {"name":"rakuten.miniapp.user.PROFILE_PHOTO", "description": "Reason to request for the custom permission"},
   *  {"name":"rakuten.miniapp.user.CONTACT_LIST", "description": "Reason to request for the custom permission"}
   * ]
   */
  requestCustomPermissions(permissionTypes: CustomPermission[]) {
    return new Promise<CustomPermissionResponse>((resolve, reject) => {
      return this.executor.exec(
        'requestCustomPermissions',
        { permissions: permissionTypes },
        success => resolve(JSON.parse(success)),
        error => reject(error)
      );
    });
  }

  /**
   * Associating shareInfo function to MiniAppBridge object.
   * This function returns the shared info action state.
   * @param {info} The shared info object.
   */
  shareInfo(info: ShareInfoType) {
    return new Promise<string>((resolve, reject) => {
      return this.executor.exec(
        'shareInfo',
        { shareInfo: info },
        success => resolve(success),
        error => reject(error)
      );
    });
  }

  /**
   * Associating getUserName function to MiniAppBridge object.
   * This function returns username from the user profile
   * (provided the rakuten.miniapp.user.USER_NAME custom permission is allowed by the user)
   * It returns error info if user had denied the custom permission
   */
  getUserName() {
    return new Promise<string>((resolve, reject) => {
      return this.executor.exec(
        'getUserName',
        null,
        userName => resolve(userName),
        error => reject(error)
      );
    });
  }

  /**
   * Associating getProfilePhoto function to MiniAppBridge object.
   * This function returns username from the user profile.
   * (provided the rakuten.miniapp.user.PROFILE_PHOTO is allowed by the user)
   * It returns error info if user had denied the custom permission
   */
  getProfilePhoto() {
    return new Promise<string>((resolve, reject) => {
      return this.executor.exec(
        'getProfilePhoto',
        null,
        profilePhoto => resolve(profilePhoto),
        error => reject(error)
      );
    });
  }

  /**
   * Associating getContacts function to MiniAppBridge object.
   * This function returns contact list from the user profile.
   * (provided the rakuten.miniapp.user.CONTACT_LIST is allowed by the user)
   * It returns error info if user had denied the custom permission
   */
  getContacts() {
    return new Promise<Contact[]>((resolve, reject) => {
      return this.executor.exec(
        'getContacts',
        null,
        contacts => resolve(JSON.parse(contacts) as Contact[]),
        error => reject(error)
      );
    });
  }

  /**
   * Associating getAccessToken function to MiniAppBridge object.
   * This function returns access token details from the host app.
   * (provided the rakuten.miniapp.user.ACCESS_TOKEN is allowed by the user)
   * It returns error info if user had denied the custom permission
   * @param {string} audience the audience the MiniApp requests for the token
   * @param {string[]} scopes the associated scopes with the requested audience
   */
  getAccessToken(audience: string, scopes: string[]) {
    return new Promise<AccessTokenData>((resolve, reject) => {
      return this.executor.exec(
        'getAccessToken',
        { audience, scopes },
        tokenData => {
          const nativeTokenData = JSON.parse(tokenData) as NativeTokenData;
          resolve(new AccessTokenData(nativeTokenData));
        },
        error => reject(error)
      );
    });
  }

  /**
   * This function does not return anything back on success.
   * @param {screenAction} The screen state that miniapp wants to set on device.
   */
  setScreenOrientation(screenAction: ScreenOrientation) {
    return new Promise<string>((resolve, reject) => {
      return this.executor.exec(
        'setScreenOrientation',
        { action: screenAction },
        success => resolve(success),
        error => reject(error)
      );
    });
  }

  /**
   * @param message The message to send to contact.
   * @returns Promise resolves with the contact id received a message.
   * Can also resolve with null response in the case that the message was not sent to a contact, such as if the user cancelled sending the message.
   * Promise rejects in the case that there was an error.
   * It returns error info if user had denied the custom permission for sending message.
   */
  sendMessageToContact(message: MessageToContact) {
    return new Promise<string | null>((resolve, reject) => {
      return this.executor.exec(
        'sendMessageToContact',
        { messageToContact: message },
        contactId => {
          if (contactId !== 'null' && contactId !== null) {
            resolve(contactId);
          } else {
            resolve(null);
          }
        },
        error => reject(error)
      );
    });
  }

  /**
   * @param id The id of the contact receiving a message.
   * @param message The message to send to contact.
   * @returns Promise resolves with the contact id received a message.
   * @see {sendMessageToContact}
   */
  sendMessageToContactId(id: string, message: MessageToContact) {
    return new Promise<string | null>((resolve, reject) => {
      return this.executor.exec(
        'sendMessageToContactId',
        { contactId: id, messageToContact: message },
        contactId => {
          if (contactId !== 'null' && contactId !== null) {
            resolve(contactId);
          } else {
            resolve(null);
          }
        },
        error => reject(error)
      );
    });
  }

  /**
   * @param message The message to send to contact.
   * @returns Promise resolves with an array of contact id which were sent the message.
   * Can also resolve with null array in the case that the message was not sent to any contacts, such as if the user cancelled sending the message.
   * Promise rejects in the case that there was an error.
   * It returns error info if user had denied the custom permission for sending message.
   */
  sendMessageToMultipleContacts(message: MessageToContact) {
    return new Promise<string[] | null>((resolve, reject) => {
      return this.executor.exec(
        'sendMessageToMultipleContacts',
        { messageToContact: message },
        contactIds => {
          if (contactIds !== 'null' && contactIds !== null) {
            resolve(JSON.parse(contactIds) as string[]);
          } else {
            resolve(null);
          }
        },
        error => reject(error)
      );
    });
  }
}

/**
 * Method to remove the callback object from the message queue after successful/error communication
 * with the native application
 * @param  {[Object]} queueObj Queue Object that holds the references of callback information.
 * @internal
 */
function removeFromMessageQueue(queueObj) {
  const messageObjIndex = mabMessageQueue.indexOf(queueObj);
  if (messageObjIndex !== -1) {
    mabMessageQueue.splice(messageObjIndex, 1);
  }
}
