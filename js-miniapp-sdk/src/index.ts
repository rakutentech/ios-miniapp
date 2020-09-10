/** @internal */

/**
 * Main entry point for SDK
 */

import { MiniApp } from './miniapp';
import { AdTypes } from './types/adTypes';
import { InterstitialAdResponse } from './types/responseTypes/interstitial';
import { RewardedAdResponse } from './types/responseTypes/rewarded';
import { ShareInfoType } from './types/ShareInfoType';
import { CustomPermissionType } from './types/CustomPermissionType';

/** @internal */
const miniAppInstance = new MiniApp();

export default miniAppInstance;
export {
  AdTypes,
  InterstitialAdResponse,
  RewardedAdResponse,
  ShareInfoType,
  CustomPermissionType,
};
