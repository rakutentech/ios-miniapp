import { expect } from 'chai';
import sinon, { mock } from 'sinon';

import * as Bridge from '../src/common-bridge';
import {
  CustomPermissionName,
  CustomPermissionStatus,
} from '../src/types/custom-permissions';
import {
  errorTypesDescriptions,
  MiniAppErrorType,
  parseMiniAppError,
  AudienceNotSupportedError,
  ScopesNotSupportedError,
  AuthorizationFailureError,
  MiniAppError,
  MessageToContact,
} from '../src';

/* tslint:disable:no-any */
const window: any = {};
(global as any).window = window;

const sandbox = sinon.createSandbox();
const mockExecutor = {
  exec: sinon.stub(),
  getPlatform: sinon.stub(),
};

const handleError = error => {};

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

describe('getToken', () => {
  it('will parse the AccessToken JSON response', () => {
    const bridge = new Bridge.MiniAppBridge(mockExecutor);
    mockExecutor.exec.callsArgWith(
      2,
      '{ "token": "test", "validUntil": 0, "scopes": { "audience": "AUD", "scopes": ["SCO1","SCO2"]} }'
    );

    return expect(
      bridge.getAccessToken('AUD', ['SCO1', 'SCO2'])
    ).to.eventually.deep.equal({
      token: 'test',
      validUntil: new Date(0),
      scopes: {
        audience: 'AUD',
        scopes: ['SCO1', 'SCO2'],
      },
    });
  });

  it('will parse the AccessToken AudienceNotSupportedError JSON response', () => {
    const bridge = new Bridge.MiniAppBridge(mockExecutor);
    mockExecutor.exec.callsArgWith(
      3,
      '{ "type": "AudienceNotSupportedError", "message": null }'
    );

    return expect(bridge.getAccessToken('AUDIENCE', ['SCOPE1', 'SCOPE2']))
      .to.eventually.be.rejected.and.be.an.instanceof(AudienceNotSupportedError)
      .and.have.property(
        'message',
        errorTypesDescriptions.get(MiniAppErrorType.AudienceNotSupportedError)
      );
  });

  it('will parse the AccessToken ScopesNotSupportedError JSON response', () => {
    const bridge = new Bridge.MiniAppBridge(mockExecutor);
    mockExecutor.exec.callsArgWith(3, '{ "type": "ScopesNotSupportedError" }');

    return expect(bridge.getAccessToken('AUDIENCE', ['SCOPE1', 'SCOPE2']))
      .to.eventually.be.rejected.and.be.an.instanceof(ScopesNotSupportedError)
      .and.have.property(
        'message',
        errorTypesDescriptions.get(MiniAppErrorType.ScopesNotSupportedError)
      );
  });

  it('will parse the AccessToken AuthorizationFailureError JSON response', () => {
    const bridge = new Bridge.MiniAppBridge(mockExecutor);
    mockExecutor.exec.callsArgWith(
      3,
      '{ "type": "AuthorizationFailureError", "message": "test message" }'
    );

    return expect(bridge.getAccessToken('AUDIENCE', ['SCOPE1', 'SCOPE2']))
      .to.eventually.be.rejected.and.be.an.instanceof(AuthorizationFailureError)
      .and.have.property('message', 'test message');
  });

  it('will parse the AccessToken error JSON response', () => {
    const bridge = new Bridge.MiniAppBridge(mockExecutor);
    mockExecutor.exec.callsArgWith(
      3,
      '{ "type": "test", "message": "test message" }'
    );

    return expect(bridge.getAccessToken('AUDIENCE', ['SCOPE1', 'SCOPE2']))
      .to.eventually.be.rejected.and.be.an.instanceof(MiniAppError)
      .and.to.include({ name: 'test', message: 'test message' });
  });

  it('will parse the AccessToken error JSON with no type response', () => {
    const bridge = new Bridge.MiniAppBridge(mockExecutor);
    mockExecutor.exec.callsArgWith(3, '{ "message": "test message" }');

    return expect(bridge.getAccessToken('AUDIENCE', ['SCOPE1', 'SCOPE2']))
      .to.eventually.be.rejected.and.be.an.instanceof(MiniAppError)
      .and.to.include({ message: 'test message' });
  });

  it('will still send an error if JSON error parsing fails', () => {
    const bridge = new Bridge.MiniAppBridge(mockExecutor);
    mockExecutor.exec.callsArgWith(3, 'an error occurred');

    return expect(
      bridge.getAccessToken('AUDIENCE', ['SCOPE1', 'SCOPE2'])
    ).to.eventually.be.rejected.and.to.equal('an error occurred');
  });
});

describe('sendMessage', () => {
  it('will parse the message JSON response for sendMessageToContact', () => {
    const bridge = new Bridge.MiniAppBridge(mockExecutor);
    mockExecutor.exec.callsArgWith(2, 'id_contact');
    const messageToContact: MessageToContact = {
      text: 'text',
      image: 'image',
      caption: 'caption',
      action: 'action',
      bannerMessage: null,
    };
    return expect(
      bridge.sendMessageToContact(messageToContact)
    ).to.eventually.deep.equal('id_contact');
  });

  it('will parse the message JSON response for sendMessageToContactId', () => {
    const bridge = new Bridge.MiniAppBridge(mockExecutor);
    mockExecutor.exec.callsArgWith(2, 'id_contact');
    const messageToContact: MessageToContact = {
      text: 'text',
      image: 'image',
      caption: 'caption',
      action: 'action',
      bannerMessage: null,
    };
    return expect(
      bridge.sendMessageToContactId('id_contact', messageToContact)
    ).to.eventually.deep.equal('id_contact');
  });

  it('will parse the message JSON response for sendMessageToMultipleContacts', () => {
    const bridge = new Bridge.MiniAppBridge(mockExecutor);
    mockExecutor.exec.callsArgWith(2, '["id_contact","id_contact2"]');
    const messageToContact: MessageToContact = {
      text: 'text',
      image: 'image',
      caption: 'caption',
      action: 'action',
      bannerMessage: null,
    };
    return expect(
      bridge.sendMessageToMultipleContacts(messageToContact)
    ).to.eventually.deep.equal(['id_contact', 'id_contact2']);
  });
});

describe('showRewardedAd', () => {
  it('will parse the Reward JSON response', () => {
    const bridge = new Bridge.MiniAppBridge(mockExecutor);
    mockExecutor.exec.callsArgWith(
      2,
      '{ "amount": 500, "type": "game bonus" }'
    );

    return expect(bridge.showRewardedAd('test_id')).to.eventually.deep.equal({
      amount: 500,
      type: 'game bonus',
    });
  });
});

describe('showInterstitialAd', () => {
  it('will return the close status string response', () => {
    const bridge = new Bridge.MiniAppBridge(mockExecutor);
    const response = 'success';
    mockExecutor.exec.callsArgWith(2, response);

    return expect(
      bridge.showInterstitialAd('test_id')
    ).to.eventually.deep.equal(response);
  });
});

describe('requestCustomPermissions', () => {
  const requestPermissions = [
    { name: CustomPermissionName.USER_NAME, description: 'test_description' },
  ];

  it('will call the platform executor', () => {
    const bridge = new Bridge.MiniAppBridge(mockExecutor);

    bridge.requestCustomPermissions(requestPermissions).catch(handleError);

    sinon.assert.calledWith(mockExecutor.exec, 'requestCustomPermissions');
  });

  it('will attach the permissions to the `permissions` key', () => {
    const bridge = new Bridge.MiniAppBridge(mockExecutor);

    bridge.requestCustomPermissions(requestPermissions).catch(handleError);

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

describe('getPoints', () => {
  it('will parse the Points JSON response', () => {
    const bridge = new Bridge.MiniAppBridge(mockExecutor);
    mockExecutor.exec.callsArgWith(
      2,
      '{ "standard": 10, "term": 20, "cash": 30 }'
    );

    return expect(bridge.getPoints()).to.eventually.deep.equal({
      standard: 10,
      term: 20,
      cash: 30,
    });
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
