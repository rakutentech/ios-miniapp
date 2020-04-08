// tslint:disable-next-line:variable-name
const MiniApp = require('./miniapp.js');

const miniAppInstance = new MiniApp();

export = function getUniqueId(): Promise<string> {
  return miniAppInstance.getUniqueId();
};
