import {
  MiniAppBridge,
  Reward,
  DevicePermission,
  CustomPermission,
  CustomPermissionResult,
  ShareInfoType,
} from '../../js-miniapp-bridge/src';

/**
 * A module layer for webapps and mobile native interaction.
 */
interface MiniAppFeatures {
  /** @returns The Promise of provided id of mini app from injected side. */
  getUniqueId(): Promise<string>;

  /** @returns The Promise of permission result of mini app from injected side. */
  requestLocationPermission(): Promise<string>;

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
   * @param info The shared data must match the property in [ShareInfoType].
   * @returns The Promise of share info action state from injected side.
   */
  shareInfo(info: ShareInfoType): Promise<string>;
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
  getPlatform();
}

/**
 * Interfaces to retrieve User profile related information
 */
export interface UserInfoProvider {
  /**
   * @returns Username saved in the host app user profile
   */
  getUserName(): Promise<string>;

  /**
   * @returns Profile photo saved in the host app user profile
   */
  getProfilePhoto(): Promise<string>;
}

/** @internal */
class UserInfo implements UserInfoProvider {
  private bridge: MiniAppBridge;

  constructor(miniAppBridge: MiniAppBridge) {
    this.bridge = miniAppBridge;
  }

  getUserName(): Promise<string> {
    return this.bridge.getUserName();
  }

  getProfilePhoto(): Promise<string> {
    return this.bridge.getProfilePhoto();
  }
}

/* tslint:disable:no-any */
export class MiniApp implements MiniAppFeatures, Ad, Platform {
  private bridge: MiniAppBridge = (window as any).MiniAppBridge;
  user: UserInfoProvider = new UserInfo(this.bridge);

  private requestPermission(permissionType: DevicePermission): Promise<string> {
    return this.bridge.requestPermission(permissionType);
  }

  getUniqueId(): Promise<string> {
    return this.bridge.getUniqueId();
  }

  requestLocationPermission(): Promise<string> {
    return this.requestPermission(DevicePermission.LOCATION);
  }

  requestCustomPermissions(
    permissions: CustomPermission[]
  ): Promise<CustomPermissionResult[]> {
    return this.bridge
      .requestCustomPermissions(permissions)
      .then(permissionResult => permissionResult.permissions);
  }

  loadInterstitialAd(id: string): Promise<string> {
    return this.bridge.loadInterstitialAd(id);
  }

  loadRewardedAd(id: string): Promise<string> {
    return this.bridge.loadRewardedAd(id);
  }

  showInterstitialAd(id: string): Promise<string> {
    return this.bridge.showInterstitialAd(id);
  }

  showRewardedAd(id: string): Promise<Reward> {
    return this.bridge.showRewardedAd(id);
  }

  shareInfo(info: ShareInfoType): Promise<string> {
    return this.bridge.shareInfo(info);
  }

  getPlatform(): string {
    let platform = 'Unknown';
    try {
      platform = this.bridge.platform;
    } catch (e) {}
    return platform;
  }
}
