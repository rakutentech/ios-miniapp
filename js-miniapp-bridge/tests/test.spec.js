const bridge = require("../src/bridge.js");
const helpers = require("../tests/helpers");
const assert = require("chai");

describe("Test Mini App Bridge execSuccessCallback is called with valid unique id", () => {
  it("will return success promise with uniqueId value", () => {
    const callback = {};
    var onSuccess = function(value) {
      assert.expect(value).to.equal("1234");
    };
    var onError = function() {};
    callback.onSuccess = onSuccess;
    callback.onError = onError;
    callback.id = Math.random();
    bridge.messageQueue.unshift(callback);
    bridge.execSuccessCallback(callback.id, "1234");
  });
});

describe("Test Mini App Bridge execSuccessCallback is called with invalid unique id", () => {
  it("will return error promise with Unknown Error", () => {
    const callback = {};
    var onSuccess = function() {};
    var onError = function(error) {
      assert.expect(error).to.equal("Unknown Error");
    };
    callback.onSuccess = onSuccess;
    callback.onError = onError;
    callback.id = Math.random();
    bridge.messageQueue.unshift(callback);
    bridge.execSuccessCallback(callback.id, "");
  });
});

describe("Test Mini App Bridge execErrorCallback is called with error message", () => {
  it("will return error promise with same error message", () => {
    const callback = {};
    var onSuccess = function() {};
    var onError = function(error) {
      assert.expect(error).to.equal("Internal Error");
    };
    callback.onSuccess = onSuccess;
    callback.onError = onError;
    callback.id = Math.random();
    bridge.messageQueue.unshift(callback);
    bridge.execErrorCallback(callback.id, "Internal Error");
  });
});

describe("Test Mini App Bridge execErrorCallback is called with no error message", () => {
  it("will return error promise with Unknown Error", () => {
    const callback = {};
    var onSuccess = function() {};
    var onError = function(error) {
      assert.expect(error).to.equal("Unknown Error");
    };
    callback.onSuccess = onSuccess;
    callback.onError = onError;
    callback.id = Math.random();
    bridge.messageQueue.unshift(callback);
    bridge.execErrorCallback(callback.id, "");
  });
});

describe("Test Mini App Bridge getUniqueId", () => {
  helpers.mockInterface(bridge);
  it("will return success promise with uniqueId value", () => {
    window.MiniAppAndroid.postMessage = helpers.mockSuccessPostMessage;
    bridge.getUniqueId().then(function(value) {
      assert.expect(value).to.equal("1234");
    });
  });
  it("will return error with message", () => {
    window.MiniAppAndroid.postMessage = helpers.mockErrorPostMessage;
    bridge.getUniqueId().catch(function(error) {
      assert.expect(error).to.equal("Internal Error");
    });
  });
});
