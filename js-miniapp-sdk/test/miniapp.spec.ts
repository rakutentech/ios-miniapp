/* tslint:disable:no-any */

import { expect } from 'chai';
import sinon from 'sinon';

import { AdTypes } from '../src/types/adTypes';
import { InterstitialAdResponse } from '../src/types/responseTypes/interstitial';
import { RewardedAdResponse } from '../src/types/responseTypes/rewarded';
import { MiniApp } from '../src/miniapp';
import { DevicePermission } from '../src/types/DevicePermission';
import {
  CustomPermissionName,
  CustomPermissionStatus,
} from '../src/types/CustomPermission';

const window: any = {};
(global as any).window = window;

window.MiniAppBridge = {
  getUniqueId: sinon.stub(),
  requestPermission: sinon.stub(),
  requestCustomPermissions: sinon.stub(),
  loadInterstitialAd: sinon.stub(),
  loadRewardedAd: sinon.stub(),
  showInterstitialAd: sinon.stub(),
  showRewardedAd: sinon.stub(),
  shareInfo: sinon.stub(),
};
const miniApp = new MiniApp();

describe('getUniqueId', () => {
  it('should retrieve the unique id from the Mini App Bridge', () => {
    window.MiniAppBridge.getUniqueId.resolves('test_mini_app_id');

    return expect(miniApp.getUniqueId()).to.eventually.equal(
      'test_mini_app_id'
    );
  });
});

describe('requestPermission', () => {
  it('should delegate to requestPermission function when request any permission', () => {
    const spy = sinon.spy(miniApp, 'requestPermission' as any);

    miniApp.requestLocationPermission();

    return expect(spy.callCount).to.equal(1);
  });

  it('should retrieve location permission result from the Mini App Bridge', () => {
    window.MiniAppBridge.requestPermission.resolves('Denied');

    return expect(miniApp.requestLocationPermission()).to.eventually.equal(
      'Denied'
    );
  });
});

describe('requestCustomPermissions', () => {
  it('should request provided custom permissions from the Mini App Bridge', () => {
    window.MiniAppBridge.requestCustomPermissions.resolves({
      permissions: [
        {
          name: CustomPermissionName.USER_NAME,
          status: CustomPermissionStatus.ALLOWED,
        },
      ],
    });

    return expect(
      miniApp.requestCustomPermissions([
        {
          name: CustomPermissionName.USER_NAME,
          description: 'test description',
        },
      ])
    ).to.eventually.deep.equal([
      {
        name: CustomPermissionName.USER_NAME,
        status: CustomPermissionStatus.ALLOWED,
      },
    ]);
  });
});

describe('showInterstitialAd', () => {
  it('should retrieve InterstitialAdResponse type of result from the Mini App Bridge', () => {
    const response: InterstitialAdResponse = {
      adType: AdTypes.INTERSTITIAL,
    };

    const adUnitId = 'xxx-xxx-xxxxxxxxxxxxx';

    window.MiniAppBridge.showInterstitialAd.resolves(response);
    return expect(miniApp.showInterstitialAd(adUnitId)).to.eventually.equal(
      response
    );
  });

  it('should retrive error response from the Mini App Bridge', () => {
    const error: Error = {
      message: 'Unknown error occured',
      name: 'Bridge error',
    };

    const adUnitId = 'xxx-xxx-xxxxxxxxxxxxx';

    window.MiniAppBridge.showInterstitialAd.resolves(error);
    return expect(miniApp.showInterstitialAd(adUnitId)).to.eventually.equal(
      error
    );
  });
});

describe('showRewardedAd', () => {
  it('should retrieve RewardedAdResponse type of result from the Mini App Bridge', () => {
    const response: RewardedAdResponse = {
      reward: { amount: 500, type: 'game bonus' },
      adType: AdTypes.REWARDED,
    };

    const adUnitId = 'xxx-xxx-xxxxxxxxxxxxx';

    window.MiniAppBridge.showRewardedAd.resolves(response);
    return expect(miniApp.showRewardedAd(adUnitId)).to.eventually.equal(
      response
    );
  });

  it('should retrieve RewardedAdResponse type of result from the Mini App Bridge and the reward is null', () => {
    const response: RewardedAdResponse = {
      adType: AdTypes.REWARDED,
    };

    const adUnitId = 'xxx-xxx-xxxxxxxxxxxxx';

    window.MiniAppBridge.showRewardedAd.resolves(response);
    return expect(miniApp.showRewardedAd(adUnitId)).to.eventually.equal(
      response
    );
  });

  it('should retrive error response from the Mini App Bridge', () => {
    const error: Error = {
      message: 'Unknown error occured',
      name: 'Bridge error',
    };

    const adUnitId = 'xxx-xxx-xxxxxxxxxxxxx';

    window.MiniAppBridge.showRewardedAd.resolves(error);
    return expect(miniApp.showRewardedAd(adUnitId)).to.eventually.equal(error);
  });
});

describe('loadInterstitialAd', () => {
  it('should retrieve response result from the Mini App Bridge once loadInterstitialAd call is successful', () => {
    const adUnitId = 'xxx-xxx-xxxxxxxxxxxxx';

    const response = {
      adUnit: adUnitId,
      adType: AdTypes.INTERSTITIAL,
      loaded: true,
    };

    window.MiniAppBridge.loadInterstitialAd.resolves(response);
    return expect(miniApp.loadInterstitialAd(adUnitId)).to.eventually.equal(
      response
    );
  });
  it('should retrive error response from the Mini App Bridge once loadInterstitialAd rejects with error', () => {
    const adUnitId = 'xxx-xxx-xxxxxxxxxxxxx';

    const error: Error = {
      message: 'Unknown error occured',
      name: 'Bridge error',
    };

    window.MiniAppBridge.loadInterstitialAd.resolves(error);
    return expect(miniApp.loadInterstitialAd(adUnitId)).to.eventually.equal(
      error
    );
  });
});

describe('loadRewardedAd', () => {
  it('should retrieve response result from the Mini App Bridge once loadRewardedAd call is successful', () => {
    const adUnitId = 'xxx-xxx-xxxxxxxxxxxxx';

    const response = null;

    window.MiniAppBridge.loadRewardedAd.resolves(response);
    return expect(miniApp.loadRewardedAd(adUnitId)).to.eventually.equal(
      response
    );
  });
  it('should retrive error response from the Mini App Bridge once loadRewardedAd rejects with error', () => {
    const adUnitId = 'xxx-xxx-xxxxxxxxxxxxx';

    const error: Error = {
      message: 'Unknown error occured',
      name: 'Bridge error',
    };

    window.MiniAppBridge.loadRewardedAd.resolves(error);
    return expect(miniApp.loadRewardedAd(adUnitId)).to.eventually.equal(error);
  });
});

describe('shareInfo', () => {
  it('should retrieve null from the MiniAppBridge once shareInfo call is successful', () => {
    const sharedInfo = {
      content: 'test content',
    };
    const response = null;

    window.MiniAppBridge.shareInfo.resolves(response);
    return expect(miniApp.shareInfo(sharedInfo)).to.eventually.equal(response);
  });
  it('should retrive error response from the MiniAppBridge once there is errors', () => {
    const sharedInfo = {
      content: 'test content',
    };

    const error = 'Bridge error';

    window.MiniAppBridge.shareInfo.resolves(error);
    return expect(miniApp.shareInfo(sharedInfo)).to.eventually.equal(error);
  });
});
