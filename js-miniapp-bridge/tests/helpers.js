var Helpers = {};
var MiniAppBridge = {};
var uniqueIdValue = "1234";
var uniqueIdError = "Internal Error";

Helpers.mockInterface = function(miniAppBridge) {
  MiniAppBridge = miniAppBridge;
  var MiniAppAndroid = {};
  window.MiniAppAndroid = MiniAppAndroid;
};

Helpers.mockSuccessPostMessage = function(action) {
  var message = JSON.parse(action);
  MiniAppBridge.execSuccessCallback(message.id, uniqueIdValue);
};

Helpers.mockErrorPostMessage = function(action) {
  var message = JSON.parse(action);
  MiniAppBridge.execErrorCallback(message.id, uniqueIdError);
};
module.exports = Helpers;
