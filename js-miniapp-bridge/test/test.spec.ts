import {
  AdTypes,
  CustomPermissionName,
  CustomPermissionStatus,
} from 'js-miniapp-sdk';
import * as Bridge from '../src/common-bridge';
import { expect } from 'chai';
import sinon, { mock } from 'sinon';

/* tslint:disable:no-any */
const window: any = {};
(global as any).window = window;

const sandbox = sinon.createSandbox();
const mockExecutor = {
  exec: sinon.stub(),
};

beforeEach(() => {
  sandbox.restore();
});

describe('execSuccessCallback', () => {
  describe('when called with valid value', () => {
    it('will return success promise with uniqueId value', () => {
      const callback = createCallback({
        onSuccess: value => expect(value).to.equal('1234'),
      });

      Bridge.mabMessageQueue.unshift(callback);
      Bridge.MiniAppBridge.prototype.execSuccessCallback(callback.id, '1234');
    });
  });

  describe('when called with invalid value', () => {
    it('will return error promise with Unknown Error', () => {
      const callback = createCallback({
        onError: error => expect(error).to.equal('Unknown Error'),
      });

      Bridge.mabMessageQueue.unshift(callback);
      Bridge.MiniAppBridge.prototype.execSuccessCallback(callback.id, '');
    });
  });
});

describe('execErrorCallback', () => {
  describe('when called with error message', () => {
    it('will return error promise with same error message', () => {
      const callback = createCallback({
        onError: error => expect(error).to.equal('Internal Error'),
      });

      Bridge.mabMessageQueue.unshift(callback);
      Bridge.MiniAppBridge.prototype.execErrorCallback(
        callback.id,
        'Internal Error'
      );
    });
  });

  describe('when called with no error message', () => {
    it('will return error promise with Unknown Error', () => {
      const callback = createCallback({
        onError: error => expect(error).to.equal('Unknown Error'),
      });

      Bridge.mabMessageQueue.unshift(callback);
      Bridge.MiniAppBridge.prototype.execErrorCallback(callback.id, '');
    });
  });
});

describe('showRewardedAd', () => {
  it('will parse the RewardedAdResponse JSON response', () => {
    const bridge = new Bridge.MiniAppBridge(mockExecutor);
    mockExecutor.exec.callsArgWith(2, '{ "adType": 1 }');

    return expect(bridge.showRewardedAd('test_id')).to.eventually.deep.equal({
      adType: AdTypes.REWARDED,
    });
  });
});

describe('showInterstitialAd', () => {
  it('will parse the InterstitialAdResponse JSON response', () => {
    const bridge = new Bridge.MiniAppBridge(mockExecutor);
    mockExecutor.exec.callsArgWith(2, '{ "adType": 0 }');

    return expect(
      bridge.showInterstitialAd('test_id')
    ).to.eventually.deep.equal({ adType: AdTypes.INTERSTITIAL });
  });
});

describe('requestCustomPermissions', () => {
  const requestPermissions = [
    { name: CustomPermissionName.USER_NAME, description: 'test_description' },
  ];

  it('will call the platform executor', () => {
    const bridge = new Bridge.MiniAppBridge(mockExecutor);

    bridge.requestCustomPermissions(requestPermissions);

    sinon.assert.calledWith(mockExecutor.exec, 'requestCustomPermissions');
  });

  it('will attach the permissions to the `permissions` key', () => {
    const bridge = new Bridge.MiniAppBridge(mockExecutor);

    bridge.requestCustomPermissions(requestPermissions);

    sinon.assert.calledWith(mockExecutor.exec, sinon.match.any, {
      permissions: requestPermissions,
    });
  });

  it('will parse the CustomPermission JSON response', () => {
    const bridge = new Bridge.MiniAppBridge(mockExecutor);
    mockExecutor.exec.callsArgWith(
      2,
      `[{"name": "${CustomPermissionName.USER_NAME}", "status": "${CustomPermissionStatus.ALLOWED}"}]`
    );

    return expect(bridge.requestCustomPermissions([])).to.eventually.deep.equal(
      [
        {
          name: CustomPermissionName.USER_NAME,
          status: CustomPermissionStatus.ALLOWED,
        },
      ]
    );
  });
});

interface CreateCallbackParams {
  onSuccess?: (success: any) => any;
  onError?: (error: string) => any;
}

function createCallback({
  onSuccess,
  onError,
}: CreateCallbackParams): Bridge.Callback {
  return {
    onSuccess: onSuccess || (() => undefined),
    onError: onError || (() => undefined),
    id: String(Math.random()),
  };
}
