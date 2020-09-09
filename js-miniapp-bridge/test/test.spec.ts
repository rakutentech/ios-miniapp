import { AdTypes, InterstitialAdResponse } from 'js-miniapp-sdk';
import * as bridge from '../src/common-bridge';
import assert from 'chai';

/* tslint:disable:no-any */
const window: any = {};
(global as any).window = window;

describe('Test Mini App Bridge execSuccessCallback is called with valid unique id', () => {
  it('will return success promise with uniqueId value', () => {
    const callback = {} as bridge.Callback;
    const onSuccess = value => {
      assert.expect(value).to.equal('1234');
    };
    const onError = () => {};
    callback.onSuccess = onSuccess;
    callback.onError = onError;
    callback.id = String(Math.random());
    bridge.mabMessageQueue.unshift(callback);
    bridge.MiniAppBridge.prototype.execSuccessCallback(callback.id, '1234');
  });
});

describe('Test Mini App Bridge execSuccessCallback is called with invalid unique id', () => {
  it('will return error promise with Unknown Error', () => {
    const callback = {} as bridge.Callback;
    const onSuccess = value => {};
    const onError = error => {
      assert.expect(error).to.equal('Unknown Error');
    };
    callback.onSuccess = onSuccess;
    callback.onError = onError;
    callback.id = String(Math.random());
    bridge.mabMessageQueue.unshift(callback);
    bridge.MiniAppBridge.prototype.execSuccessCallback(callback.id, '');
  });
});

describe('Test Mini App Bridge execErrorCallback is called with error message', () => {
  it('will return error promise with same error message', () => {
    const callback = {} as bridge.Callback;
    const onSuccess = value => {};
    const onError = error => {
      assert.expect(error).to.equal('Internal Error');
    };
    callback.onSuccess = onSuccess;
    callback.onError = onError;
    callback.id = String(Math.random());
    bridge.mabMessageQueue.unshift(callback);
    bridge.MiniAppBridge.prototype.execErrorCallback(
      callback.id,
      'Internal Error'
    );
  });
});

describe('Test Mini App Bridge execErrorCallback is called with no error message', () => {
  it('will return error promise with Unknown Error', () => {
    const callback = {} as bridge.Callback;
    const onSuccess = value => {};
    const onError = error => {
      assert.expect(error).to.equal('Unknown Error');
    };
    callback.onSuccess = onSuccess;
    callback.onError = onError;
    callback.id = String(Math.random());
    bridge.mabMessageQueue.unshift(callback);
    bridge.MiniAppBridge.prototype.execErrorCallback(callback.id, '');
  });
});

describe('Test Mini App Bridge execSuccessCallback is called with valid ad response', () => {
  it('will return success promise and typecast the response JSON string successfully', () => {
    const callback = {} as bridge.Callback;
    const adResponse: InterstitialAdResponse = {
      adType: AdTypes.INTERSTITIAL,
    };

    const jsonAdresponse = '{ "adType": 0 }';

    const onSuccess = value => {
      assert.expect(value).to.equal(jsonAdresponse);
      assert
        .expect(JSON.parse(value) as InterstitialAdResponse)
        .to.deep.equal(adResponse);
    };
    const onError = () => {};
    callback.onSuccess = onSuccess;
    callback.onError = onError;
    callback.id = String(Math.random());
    bridge.mabMessageQueue.unshift(callback);
    bridge.MiniAppBridge.prototype.execSuccessCallback(
      callback.id,
      jsonAdresponse
    );
  });
});

describe('Test Mini App Bridge execSuccessCallback is called with valid load interstitial ad response', () => {
  it('will resolve successful promise', () => {
    const callback = {} as bridge.Callback;
    const adResponse = null;

    const jsonAdresponse = 'null';

    const onSuccess = value => {
      assert.expect(value).to.equal(jsonAdresponse);
      assert.expect(JSON.parse(value)).to.deep.equal(adResponse);
    };
    const onError = () => {};
    callback.onSuccess = onSuccess;
    callback.onError = onError;
    callback.id = String(Math.random());
    bridge.mabMessageQueue.unshift(callback);
    bridge.MiniAppBridge.prototype.execSuccessCallback(
      callback.id,
      jsonAdresponse
    );
  });
  it('will reject with an error', () => {
    const callback = {} as bridge.Callback;
    const errorResponse = new Error('Internal error');

    const onError = error => {
      assert.expect(error).to.equal(errorResponse);
    };
    callback.onSuccess = () => {};
    callback.onError = onError;
    callback.id = String(Math.random());
    bridge.mabMessageQueue.unshift(callback);
    bridge.MiniAppBridge.prototype.execErrorCallback(
      callback.id,
      errorResponse
    );
  });
});
