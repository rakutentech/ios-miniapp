import {
  Reward,
  DevicePermission,
  CustomPermission,
  CustomPermissionName,
  CustomPermissionResult,
  CustomPermissionStatus,
  ShareInfoType,
  ScreenOrientation,
  Points,
  HostEnvironmentInfo,
  Platform as HostPlatform,
} from '../../js-miniapp-bridge/src';
import { UserInfoProvider, UserInfo } from './modules/user-info';
import { ChatService } from './modules/chat-service';
import { getBridge } from './utils';

/**
 * A module layer for webapps and mobile native interaction.
 */
interface MiniAppFeatures {
  /**
   * Request the mini app's unique id from the host app.
   * @returns The Promise of provided id of mini app from injected side.
   */
  getUniqueId(): Promise<string>;

  /**
   * Request the location permission from the host app.
   * You must call this before using `navigator.geolocation`.
   * This will request both the Android/iOS device permission for location (if not yet granted to the host app),
   * and the custom permission for location {@link CustomPermissionName.LOCATION}.
   * @param permissionDescription Description of location permission.
   * @returns The Promise of permission result of mini app from injected side.
   * Rejects the promise if the user denied the location permission (either the device permission or custom permission).
   */
  requestLocationPermission(permissionDescription?: string): Promise<string>;

  /**
   *
   * Request that the user grant custom permissions related to accessing user data.
   * Typically, this will show a dialog in the Host App asking the user grant access to your Mini App.
   * You can pass multiple permissions at once and the Host App will request all of those permissions within a single dialog.
   *
   * @param permissions An array containing CustomPermission objects - permission name and description
   * @returns Promise with the custom permission results - "ALLOWED" or "DENIED" for each permission
   */
  requestCustomPermissions(
    permissions: CustomPermission[]
  ): Promise<CustomPermissionResult[]>;

  /**
   * Share text data with another App or with the host app.
   * @param info The shared data must match the property in [ShareInfoType].
   * @returns The Promise of share info action state from injected side.
   */
  shareInfo(info: ShareInfoType): Promise<string>;

  /**
   * Swap and lock the screen orientation.
   * There is no guarantee that all hostapps and devices allow the force screen change so MiniApp should not rely on this.
   * @param screenOrientation The action that miniapp wants to request on device.
   * @returns The Promise of screen action state from injected side.
   */
  setScreenOrientation(screenOrientation: ScreenOrientation): Promise<string>;

  /**
   * Request the point balance from the host app.
   * @returns Promise of the provided point balance from mini app.
   */
  getPoints(): Promise<Points>;

  /**
   * Request the host environment information.
   * @returns Promise of the provided environment info from mini app.
   */
  getHostEnvironmentInfo(): Promise<HostEnvironmentInfo>;
}

/**
 * A contract declaring the interaction mechanism between mini-apps and native host app to display ads.
 */
interface Ad {
  /**
   * Loads the specified Interstittial Ad Unit ID.
   * Can be called multiple times to pre-load multiple ads.
   * Promise is resolved when successfully loaded.
   * @returns The Promise of load success response.
   * Promise is rejected if failed to load.
   */
  loadInterstitialAd(id: string): Promise<string>;

  /**
   * Loads the specified Rewarded Ad Unit ID.
   * Can be called multiple times to pre-load multiple ads.
   * Promise is resolved when successfully loaded.
   * @returns The Promise of load success response.
   * Promise is rejected if failed to load.
   */
  loadRewardedAd(id: string): Promise<string>;

  /**
   * Shows the Interstitial Ad for the specified ID.
   * Promise is resolved after the user closes the Ad.
   * @returns The Promise of close success response.
   * Promise is rejected if the Ad failed to display wasn't loaded first using MiniApp.loadInterstitialAd.
   */
  showInterstitialAd(id: string): Promise<string>;

  /**
   * Shows the Rewarded Ad for the specified ID.
   * Promise is resolved with an object after the user closes the Ad. The object contains the reward earned by the user.
   * Reward will be null if the user did not earn the reward.
   * @returns The Promise of Rewarded ad response result from injected side.
   * Promise is rejected if the Ad failed to display wasn't loaded first using MiniApp.loadRewardedAds.
   */
  showRewardedAd(id: string): Promise<Reward>;
}

interface Platform {
  /**
   * Detect which platform your mini app is running on.
   * @returns `Android`, `iOS`, or `Unknown`
   */
  getPlatform(): string;
}

export class MiniApp implements MiniAppFeatures, Ad, Platform {
  user: UserInfoProvider = new UserInfo();
  chatService = new ChatService();

  private requestPermission(permissionType: DevicePermission): Promise<string> {
    return getBridge().requestPermission(permissionType);
  }

  getUniqueId(): Promise<string> {
    return getBridge().getUniqueId();
  }

  requestLocationPermission(permissionDescription = ''): Promise<string> {
    const locationPermission = [
      {
        name: CustomPermissionName.LOCATION,
        description: permissionDescription,
      },
    ];

    return this.requestCustomPermissions(locationPermission)
      .then(permission =>
        permission.find(
          result =>
            result.status === CustomPermissionStatus.ALLOWED ||
            // Case where older Android SDK doesn't support the Location custom permission
            result.status === CustomPermissionStatus.PERMISSION_NOT_AVAILABLE
        )
      )
      .catch(error =>
        // Case where older iOS SDK doesn't support the Location custom permission
        typeof error === 'string' &&
        error.startsWith('invalidCustomPermissionsList')
          ? Promise.resolve(true)
          : Promise.reject(error)
      )
      .then(hasPermission =>
        hasPermission
          ? this.requestPermission(DevicePermission.LOCATION)
          : Promise.reject('User denied location permission to this mini app.')
      );
  }

  requestCustomPermissions(
    permissions: CustomPermission[]
  ): Promise<CustomPermissionResult[]> {
    return getBridge()
      .requestCustomPermissions(permissions)
      .then(permissionResult => permissionResult.permissions);
  }

  loadInterstitialAd(id: string): Promise<string> {
    return getBridge().loadInterstitialAd(id);
  }

  loadRewardedAd(id: string): Promise<string> {
    return getBridge().loadRewardedAd(id);
  }

  showInterstitialAd(id: string): Promise<string> {
    return getBridge().showInterstitialAd(id);
  }

  showRewardedAd(id: string): Promise<Reward> {
    return getBridge().showRewardedAd(id);
  }

  shareInfo(info: ShareInfoType): Promise<string> {
    return getBridge().shareInfo(info);
  }

  getPlatform(): string {
    let platform = 'Unknown';
    try {
      platform = getBridge().platform;
    } catch (e) {}
    return platform;
  }

  setScreenOrientation(screenOrientation: ScreenOrientation): Promise<string> {
    return getBridge().setScreenOrientation(screenOrientation);
  }

  getPoints(): Promise<Points> {
    return getBridge().getPoints();
  }

  getHostEnvironmentInfo(): Promise<HostEnvironmentInfo> {
    return getBridge()
      .getHostEnvironmentInfo()
      .then(info => {
        info.platform = getBridge().platform as HostPlatform;
        return info;
      });
  }
}
