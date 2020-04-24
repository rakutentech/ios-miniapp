/* tslint:disable:no-any */

import { expect } from 'chai';
import sinon from 'sinon';

import { MiniAppImp } from '../src/miniapp';

const window: any = {};
(global as any).window = window;

describe('getUniqueId', () => {
  before(() => {
    window.MiniAppBridge = {
      getUniqueId: sinon.stub(),
    };
  });

  it('should retrieve the unique id from the Mini App Bridge', () => {
    window.MiniAppBridge.getUniqueId.resolves('test_mini_app_id');

    const miniApp = new MiniAppImp();

    return expect(miniApp.getUniqueId()).to.eventually.equal(
      'test_mini_app_id'
    );
  });
});
