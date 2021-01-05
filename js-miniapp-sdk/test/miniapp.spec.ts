/* tslint:disable:no-any */

import { expect } from 'chai';
import sinon from 'sinon';

import {
  Reward,
  CustomPermissionName,
  CustomPermissionStatus,
  ScreenOrientation,
} from '../../js-miniapp-bridge/src';
import { MiniApp } from '../src/miniapp';

const sandbox = sinon.createSandbox();
beforeEach(() => {
  sandbox.restore();
  sandbox.reset();
});

const window: any = {};
(global as any).window = window;

window.MiniAppBridge = {
  getUniqueId: sandbox.stub(),
  requestPermission: sandbox.stub(),
  requestCustomPermissions: sandbox.stub(),
  loadInterstitialAd: sandbox.stub(),
  loadRewardedAd: sandbox.stub(),
  showInterstitialAd: sandbox.stub(),
  showRewardedAd: sandbox.stub(),
  shareInfo: sandbox.stub(),
  getPlatform: sandbox.stub(),
  getUserName: sandbox.stub(),
  getProfilePhoto: sandbox.stub(),
  getContacts: sandbox.stub(),
  getAccessToken: sandbox.stub(),
  setScreenOrientation: sandbox.stub(),
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

describe('requestLocationPermission', () => {
  beforeEach(() => {
    window.MiniAppBridge.requestCustomPermissions.resolves({
      permissions: [
        {
          name: CustomPermissionName.LOCATION,
          status: CustomPermissionStatus.ALLOWED,
        },
      ],
    });
    window.MiniAppBridge.requestPermission.resolves('Accept');
  });

  it('should delegate to requestPermission function when request location permission', () => {
    const spy = sinon.spy(miniApp, 'requestPermission' as any);

    return miniApp
      .requestLocationPermission()
      .then(denied => expect(spy.callCount).to.equal(1));
  });

  it('should retrieve location permission result from the Mini App Bridge', () => {
    window.MiniAppBridge.requestPermission.resolves('Denied');

    return expect(miniApp.requestLocationPermission()).to.eventually.equal(
      'Denied'
    );
  });

  it('should request location custom permission', () => {
    return miniApp.requestLocationPermission('test_description')
      .then(() => {
        sinon.assert.calledWith(window.MiniAppBridge.requestCustomPermissions, [
          {
            name: CustomPermissionName.LOCATION,
            description: 'test_description',
          },
        ]);
      })
  });

  it('should handle case where Android SDK does not support location custom permission', () => {
    window.MiniAppBridge.requestCustomPermissions.resolves({
      permissions: [
        {
          name: CustomPermissionName.LOCATION,
          status: CustomPermissionStatus.PERMISSION_NOT_AVAILABLE,
        },
      ],
    });

    return expect(miniApp.requestLocationPermission()).to.eventually.equal(
      'Accept'
    );
  });

  it('should handle case where iOS SDK does not support location custom permission', () => {
    window.MiniAppBridge.requestCustomPermissions.returns(
      Promise.reject('invalidCustomPermissionsList: test description')
    );

    return expect(miniApp.requestLocationPermission()).to.eventually.equal(
      'Accept'
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
  it('should retrieve close response from the Mini App Bridge', () => {
    const response = 'closed';

    const adUnitId = 'xxx-xxx-xxxxxxxxxxxxx';

    window.MiniAppBridge.showInterstitialAd.resolves(response);
    return expect(miniApp.showInterstitialAd(adUnitId)).to.eventually.equal(
      response
    );
  });

  it('should retrive error response from the Mini App Bridge', () => {
    const error = 'error';

    const adUnitId = 'xxx-xxx-xxxxxxxxxxxxx';

    window.MiniAppBridge.showInterstitialAd.resolves(error);
    return expect(miniApp.showInterstitialAd(adUnitId)).to.eventually.equal(
      error
    );
  });
});

describe('showRewardedAd', () => {
  it('should retrieve Reward type of result from the Mini App Bridge', () => {
    const response: Reward = {
      amount: 500,
      type: 'game bonus',
    };

    const adUnitId = 'xxx-xxx-xxxxxxxxxxxxx';

    window.MiniAppBridge.showRewardedAd.resolves(response);
    return expect(miniApp.showRewardedAd(adUnitId)).to.eventually.equal(
      response
    );
  });

  it('should retrieve null when the user does not earn reward', () => {
    const adUnitId = 'xxx-xxx-xxxxxxxxxxxxx';

    window.MiniAppBridge.showRewardedAd.resolves(null);
    return expect(miniApp.showRewardedAd(adUnitId)).to.eventually.equal(null);
  });

  it('should retrive error response from the Mini App Bridge', () => {
    const error = 'error';

    const adUnitId = 'xxx-xxx-xxxxxxxxxxxxx';

    window.MiniAppBridge.showRewardedAd.resolves(error);
    return expect(miniApp.showRewardedAd(adUnitId)).to.eventually.equal(error);
  });
});

describe('loadInterstitialAd', () => {
  it('should retrieve the load result from the Mini App Bridge', () => {
    const adUnitId = 'xxx-xxx-xxxxxxxxxxxxx';

    const response = 'success';

    window.MiniAppBridge.loadInterstitialAd.resolves(response);
    return expect(miniApp.loadInterstitialAd(adUnitId)).to.eventually.equal(
      response
    );
  });
  it('should retrive error response from the Mini App Bridge once loadInterstitialAd rejects with error', () => {
    const adUnitId = 'xxx-xxx-xxxxxxxxxxxxx';

    const error = 'error';

    window.MiniAppBridge.loadInterstitialAd.resolves(error);
    return expect(miniApp.loadInterstitialAd(adUnitId)).to.eventually.equal(
      error
    );
  });
});

describe('loadRewardedAd', () => {
  it('should retrieve the load result from the Mini App Bridge', () => {
    const adUnitId = 'xxx-xxx-xxxxxxxxxxxxx';

    const response = 'success';

    window.MiniAppBridge.loadRewardedAd.resolves(response);
    return expect(miniApp.loadRewardedAd(adUnitId)).to.eventually.equal(
      response
    );
  });
  it('should retrive error response from the Mini App Bridge once loadRewardedAd rejects with error', () => {
    const adUnitId = 'xxx-xxx-xxxxxxxxxxxxx';

    const error = 'error';

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

describe('getUserName', () => {
  it('should retrieve username from the MiniAppBridge if getUserName is called', () => {
    const response = 'Rakuten';

    window.MiniAppBridge.getUserName.resolves(response);
    return expect(miniApp.user.getUserName()).to.eventually.equal(response);
  });
});

describe('getProfilePhoto', () => {
  it('should retrieve Profile photo in Base 64 string from the MiniAppBridge if getProfilePhoto is called', () => {
    const response =
      'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8wmD0HwAFPQInf/fUWQAAAABJRU5ErkJggg==';

    window.MiniAppBridge.getProfilePhoto.resolves(response);
    return expect(miniApp.user.getProfilePhoto()).to.eventually.equal(response);
  });
});

describe('getContacts', () => {
  it('should retrieve contact list from the MiniAppBridge when request is successful', () => {
    const response = [
      {
        id: 'test_contact_id',
      },
    ];

    window.MiniAppBridge.getContacts.resolves(response);
    return expect(miniApp.user.getContacts()).to.eventually.equal(response);
  });
});

describe('getAccessToken', () => {
  it('should retrieve AccessTokenData from the MiniAppBridge when request is successful', () => {
    const response = {
      token: 'test_token',
      validUntil: 0,
    };

    window.MiniAppBridge.getAccessToken.resolves(response);
    return expect(miniApp.user.getAccessToken()).to.eventually.equal(response);
  });
});

describe('requestScreenOrientation', () => {
  it('should retrieve success from the MiniAppBridge when request is successful', () => {
    const response = 'success';

    window.MiniAppBridge.setScreenOrientation.resolves(response);
    return expect(
      miniApp.setScreenOrientation(ScreenOrientation.LOCK_LANDSCAPE)
    ).to.eventually.equal(response);
  });

  it('should retrive error response from the MiniAppBridge once there is errors', () => {
    const error = 'Bridge error';

    window.MiniAppBridge.setScreenOrientation.resolves(error);
    return expect(
      miniApp.setScreenOrientation(ScreenOrientation.LOCK_PORTRAIT)
    ).to.eventually.equal(error);
  });
});
