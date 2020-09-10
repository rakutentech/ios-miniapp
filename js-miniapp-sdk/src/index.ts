/** @internal */

/**
 * Main entry point for SDK
 */

import { MiniApp } from './miniapp';
import { AdTypes } from './types/adTypes';
import { InterstitialAdResponse } from './types/responseTypes/interstitial';
import { RewardedAdResponse } from './types/responseTypes/rewarded';
import { ShareInfoType } from './types/ShareInfoType';
import {
  CustomPermission,
  CustomPermissionName,
  CustomPermissionStatus,
  CustomPermissionResult,
} from './types/CustomPermission';

/** @internal */
const miniAppInstance = new MiniApp();

export default miniAppInstance;
export {
  AdTypes,
  InterstitialAdResponse,
  CustomPermission,
  CustomPermissionName,
  CustomPermissionStatus,
  CustomPermissionResult,
  RewardedAdResponse,
  ShareInfoType,
};
