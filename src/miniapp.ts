export interface MiniAppMessageFactory {
    getUniqueId(): String
};

export declare let MiniAppMessageInterface:MiniAppMessageFactory;

export namespace MiniApp {
    export function getUniqueId(): String {
      return MiniAppMessageInterface.getUniqueId()
    }
}
