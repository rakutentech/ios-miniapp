import { InterstitialAdResponse } from './types/responseTypes/interstitial';
import {
  CustomPermission,
  CustomPermissionResult,
} from './types/CustomPermission';
import { DevicePermission } from './types/DevicePermission';
import { RewardedAdResponse } from './types/responseTypes/rewarded';
import { ShareInfoType } from './types/ShareInfoType';

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
   * @returns The Promise of load ad response result from injected side.
   * Promise is rejected if failed to load.
   */
  loadInterstitialAd(id: string): Promise<null | Error>;

  /**
   * Loads the specified Rewarded Ad Unit ID.
   * Can be called multiple times to pre-load multiple ads.
   * Promise is resolved when successfully loaded.
   * * @returns The Promise of load ad response result from injected side.
   * Promise is rejected if failed to load.
   */
  loadRewardedAd(id: string): Promise<null | Error>;

  /**
   * Shows the Interstitial Ad for the specified ID.
   * Promise is resolved after the user closes the Ad.
   * @returns The Promise of Interstitial ad response result from injected side.
   * Promise is rejected if the Ad failed to display wasn't loaded first using MiniApp.loadRewardedAds.
   */
  showInterstitialAd(id: string): Promise<InterstitialAdResponse>;

  /**
   * Shows the Rewarded Ad for the specified ID.
   * Promise is resolved with an object after the user closes the Ad. The object contains the reward earned by the user.
   * Reward will be null if the user did not earn the reward.
   * @returns The Promise of Rewarded ad response result from injected side.
   * Promise is rejected if the Ad failed to display wasn't loaded first using MiniApp.loadRewardedAds.
   */
  showRewardedAd(id: string): Promise<RewardedAdResponse>;
}

/* tslint:disable:no-any */
export class MiniApp implements MiniAppFeatures, Ad {
  private requestPermission(permissionType: string): Promise<string> {
    return (window as any).MiniAppBridge.requestPermission(permissionType);
  }

  getUniqueId(): Promise<string> {
    return (window as any).MiniAppBridge.getUniqueId();
  }

  requestLocationPermission(): Promise<string> {
    return this.requestPermission(DevicePermission.LOCATION);
  }

  requestCustomPermissions(
    permissions: CustomPermission[]
  ): Promise<CustomPermissionResult[]> {
    return (window as any).MiniAppBridge.requestCustomPermissions(
      permissions
    ).then(permissionResult => permissionResult.permissions);
  }

  loadInterstitialAd(id: string): Promise<null | Error> {
    return (window as any).MiniAppBridge.loadInterstitialAd(id);
  }

  loadRewardedAd(id: string): Promise<null | Error> {
    return (window as any).MiniAppBridge.loadRewardedAd(id);
  }

  showInterstitialAd(id: string): Promise<InterstitialAdResponse> {
    return (window as any).MiniAppBridge.showInterstitialAd(id);
  }

  showRewardedAd(id: string): Promise<RewardedAdResponse> {
    return (window as any).MiniAppBridge.showRewardedAd(id);
  }

  shareInfo(info: ShareInfoType): Promise<string> {
    return (window as any).MiniAppBridge.shareInfo(info);
  }
}
