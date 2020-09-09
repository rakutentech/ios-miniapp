/** @internal */

/**
 * Main entry point for SDK
 */

import { MiniApp } from './miniapp';
import { AdTypes } from './types/adTypes';
import { InterstitialAdResponse } from './types/responseTypes/interstitial';
import { RewardedAdResponse } from './types/responseTypes/rewarded';

/** @internal */
const miniAppInstance = new MiniApp();

export default miniAppInstance;
export { AdTypes, InterstitialAdResponse, RewardedAdResponse };
