(function(){function r(e,n,t){function o(i,f){if(!n[i]){if(!e[i]){var c="function"==typeof require&&require;if(!f&&c)return c(i,!0);if(u)return u(i,!0);var a=new Error("Cannot find module '"+i+"'");throw a.code="MODULE_NOT_FOUND",a}var p=n[i]={exports:{}};e[i][0].call(p.exports,function(r){var n=e[i][1][r];return o(n||r)},p,p.exports,r,e,n,t)}return n[i].exports}for(var u="function"==typeof require&&require,i=0;i<t.length;i++)o(t[i]);return o}return r})()({1:[function(require,module,exports){
"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
/* tslint:disable:no-any */
var mabMessageQueue = [];
exports.mabMessageQueue = mabMessageQueue;
var MiniAppBridge = /** @class */ (function () {
    function MiniAppBridge(executor) {
        this.executor = executor;
    }
    /**
     * Success Callback method that will be called from native side
     * to this bridge. This method will send back the value to the
     * mini apps that uses promises
     * @param  {[String]} messageId Message ID which will be used to get callback object from messageQueue
     * @param  {[String]} value Response value sent from the native on invoking the action command
     */
    MiniAppBridge.prototype.execSuccessCallback = function (messageId, value) {
        var queueObj = mabMessageQueue.filter(function (callback) { return callback.id === messageId; })[0];
        if (value) {
            queueObj.onSuccess(value);
        }
        else {
            queueObj.onError('Unknown Error');
        }
        removeFromMessageQueue(queueObj);
    };
    /**
     * Error Callback method that will be called from native side
     * to this bridge. This method will send back the error message to the
     * mini apps that uses promises
     * @param  {[String]} messageId Message ID which will be used to get callback object from messageQueue
     * @param  {[String]} errorMessage Error message sent from the native on invoking the action command
     */
    MiniAppBridge.prototype.execErrorCallback = function (messageId, errorMessage) {
        var queueObj = mabMessageQueue.filter(function (callback) { return callback.id === messageId; })[0];
        if (!errorMessage) {
            errorMessage = 'Unknown Error';
        }
        queueObj.onError(errorMessage);
        removeFromMessageQueue(queueObj);
    };
    /**
     * Associating getUniqueId function to MiniAppBridge object
     */
    MiniAppBridge.prototype.getUniqueId = function () {
        var _this = this;
        return new Promise(function (resolve, reject) {
            return _this.executor.exec('getUniqueId', null, function (id) { return resolve(id); }, function (error) { return reject(error); });
        });
    };
    /**
     * Associating requestPermission function to MiniAppBridge object
     * @param {string} permissionType Type of permission that is requested. For eg., location
     */
    MiniAppBridge.prototype.requestPermission = function (permissionType) {
        var _this = this;
        return new Promise(function (resolve, reject) {
            return _this.executor.exec('requestPermission', { permission: permissionType }, function (success) { return resolve(success); }, function (error) { return reject(error); });
        });
    };
    /**
     * Associating requestCustomPermissions function to MiniAppBridge object
     * @param [CustomPermission[] permissionTypes, Types of custom permissions that are requested
     * using an Array including the parameters eg. name, description.
     *
     * For eg., Miniapps can pass the array of valid custom permissions as following
     * [
     *  {"name":"rakuten.miniapp.user.USER_NAME", "description": "Reason to request for the custom permission"},
     *  {"name":"rakuten.miniapp.user.PROFILE_PHOTO", "description": "Reason to request for the custom permission"},
     *  {"name":"rakuten.miniapp.user.CONTACT_LIST", "description": "Reason to request for the custom permission"}
     * ]
     */
    MiniAppBridge.prototype.requestCustomPermissions = function (permissionTypes) {
        var _this = this;
        return new Promise(function (resolve, reject) {
            return _this.executor.exec('requestCustomPermissions', { permissions: permissionTypes }, function (success) { return resolve(success); }, function (error) { return reject(error); });
        });
    };
    return MiniAppBridge;
}());
exports.MiniAppBridge = MiniAppBridge;
/**
 * Method to remove the callback object from the message queue after successfull/error communication
 * with the native application
 * @param  {[Object]} queueObj Queue Object that holds the references of callback informations
 */
function removeFromMessageQueue(queueObj) {
    var messageObjIndex = mabMessageQueue.indexOf(queueObj);
    if (messageObjIndex !== -1) {
        mabMessageQueue.splice(messageObjIndex, 1);
    }
}

},{}],2:[function(require,module,exports){
"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
var common_bridge_1 = require("../common-bridge");
/* tslint:disable:no-any */
var uniqueId = Math.random();
// tslint:disable-next-line: variable-name
var GeolocationPositionError = {
    PERMISSION_DENIED: 1,
    POSITION_UNAVAILABLE: 2,
    TIMEOUT: 3,
};
var IOSExcecutor = /** @class */ (function () {
    function IOSExcecutor() {
    }
    IOSExcecutor.prototype.exec = function (action, param, onSuccess, onError) {
        var callback = {};
        callback.onSuccess = onSuccess;
        callback.onError = onError;
        callback.id = String(++uniqueId);
        common_bridge_1.mabMessageQueue.unshift(callback);
        window.webkit.messageHandlers.MiniAppiOS.postMessage(JSON.stringify({ action: action, param: param, id: callback.id }));
    };
    return IOSExcecutor;
}());
var iOSExcecutor = new IOSExcecutor();
window.MiniAppBridge = new common_bridge_1.MiniAppBridge(iOSExcecutor);
navigator.geolocation.getCurrentPosition = function (success, error, options) {
    return iOSExcecutor.exec('getCurrentPosition', { locationOptions: options }, function (value) {
        try {
            var parsedData = JSON.parse(value);
            success(parsedData);
        }
        catch (error) {
            error({
                code: GeolocationPositionError.POSITION_UNAVAILABLE,
                message: 'Failed to parse location object from MiniAppBridge: ' + error,
            });
        }
    }, function (error) { return console.error(error); });
};

},{"../common-bridge":1}]},{},[2]);
