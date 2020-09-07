import { AdTypes } from '../../adTypes';

/**
 * A contract declaring the reward response, consists of amount and type of the reward
 */
export interface Reward {
  amount?: number;
  type?: string;
}
/**
 * A contract declaring the interaction mechanism between Rewarded ad type response from native SDK
 */
export interface RewardedAdResponse {
  reward?: Reward;
  adType: AdTypes.REWARDED;
}
