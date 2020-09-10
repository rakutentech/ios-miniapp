/* tslint:disable:no-any */

import {
  AdTypes,
  InterstitialAdResponse,
  CustomPermission,
  CustomPermissionResult,
  RewardedAdResponse,
  ShareInfoType,
} from 'js-miniapp-sdk';

const mabMessageQueue: Callback[] = [];
export { mabMessageQueue };

export interface Callback {
  id: string;
  onSuccess: (value: string) => void;
  onError: (error: string) => void;
}

export interface CustomPermissionResponse {
  permissions: CustomPermissionResult[];
}

export interface PlatformExecutor {
  /**
   * Method to call the native interface methods for respective platforms
   * such as iOS & Android
   * @param  {[String]} action Action command/interface name that native side need to execute
   * @param  {Object} param Object that contains request parameter values like permissions.
   * For eg., {permission: 'location'}
   * @param  {[Function]} onSuccess Success callback function
   * @param  {[Function]} onError Error callback function
   */
  exec(
    action: string,
    param: any,
    onSuccess: (value: string) => void,
    onError: (error: string) => void
  ): void;
}

export class MiniAppBridge {
  executor: PlatformExecutor;

  constructor(executor: PlatformExecutor) {
    this.executor = executor;
  }

  /**
   * Success Callback method that will be called from native side
   * to this bridge. This method will send back the value to the
   * mini apps that uses promises
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
   * mini apps that uses promises
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
   * Associating getUniqueId function to MiniAppBridge object
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
   * Associating requestPermission function to MiniAppBridge object
   * @param {string} permissionType Type of permission that is requested. For eg., location
   */
  requestPermission(permissionType: string) {
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
   * Associating showInterstitialAd function to MiniAppBridge object
   * @param {string} id ad unit id of the intertitial ad
   */
  showInterstitialAd(id: string) {
    return new Promise<InterstitialAdResponse>((resolve, reject) => {
      return this.executor.exec(
        'showAd',
        { adType: AdTypes.INTERSTITIAL, adUnitId: id },
        adResponse => resolve(JSON.parse(adResponse) as InterstitialAdResponse),
        error => reject(error)
      );
    });
  }

  /**
   * Associating loadInterstitialAd function to MiniAppBridge object.
   * This function preloads interstitial ad before they are requested for display.
   * Can be called multiple times to pre-load multiple ads.
   * @param {string} id ad unit id of the intertitial ad that needs to be loaded.
   */
  loadInterstitialAd(id: string) {
    return new Promise<null | Error>((resolve, reject) => {
      return this.executor.exec(
        'loadAd',
        { adType: AdTypes.INTERSTITIAL, adUnitId: id },
        loadResponse => resolve(JSON.parse(loadResponse) as null | Error),
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
    return new Promise<null | Error>((resolve, reject) => {
      return this.executor.exec(
        'loadAd',
        { adType: AdTypes.REWARDED, adUnitId: id },
        loadResponse => resolve(JSON.parse(loadResponse) as null | Error),
        error => reject(error)
      );
    });
  }

  /**
   * Associating showRewardedAd function to MiniAppBridge object
   * @param {string} id ad unit id of the Rewarded ad
   */
  showRewardedAd(id: string) {
    return new Promise<RewardedAdResponse>((resolve, reject) => {
      return this.executor.exec(
        'showAd',
        { adType: AdTypes.REWARDED, adUnitId: id },
        adResponse => resolve(JSON.parse(adResponse) as RewardedAdResponse),
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
   * This function does not return anything back on success.
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
}

/**
 * Method to remove the callback object from the message queue after successfull/error communication
 * with the native application
 * @param  {[Object]} queueObj Queue Object that holds the references of callback informations
 */
function removeFromMessageQueue(queueObj) {
  const messageObjIndex = mabMessageQueue.indexOf(queueObj);
  if (messageObjIndex !== -1) {
    mabMessageQueue.splice(messageObjIndex, 1);
  }
}
