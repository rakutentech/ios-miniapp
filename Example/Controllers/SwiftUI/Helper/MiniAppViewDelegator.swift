import Foundation
import MiniApp

class MiniAppViewDelegator: MiniAppMessageDelegate {

    var miniAppId: String
    var miniAppVersion: String?

    var onSendMessage: (() -> Void)?

    init(miniAppId: String = "", miniAppVersion: String? = nil) {
        self.miniAppId = miniAppId
        self.miniAppVersion = miniAppVersion
    }

    func getUniqueId(completionHandler: @escaping (Result<String?, MASDKError>) -> Void) {
        completionHandler(.success("MAUID-\(miniAppId.prefix(8))-\((miniAppVersion ?? "").prefix(8))"))
    }

    func downloadFile(fileName: String, url: String, headers: DownloadHeaders, completionHandler: @escaping (Result<String, MASDKDownloadFileError>) -> Void) {
        //
    }

    func sendMessageToContact(_ message: MessageToContact, completionHandler: @escaping (Result<String?, MASDKError>) -> Void) {
        onSendMessage?()
    }

    func sendMessageToContactId(_ contactId: String, message: MessageToContact, completionHandler: @escaping (Result<String?, MASDKError>) -> Void) {
        //
    }

    func sendMessageToMultipleContacts(_ message: MessageToContact, completionHandler: @escaping (Result<[String]?, MASDKError>) -> Void) {
        onSendMessage?()
    }

    func getContacts(completionHandler: @escaping (Result<[MAContact]?, MASDKError>) -> Void) {
        if miniAppId.starts(with: "404") {
            completionHandler(.success([
                MAContact(id: "1", name: "John Doe", email: "joh@doe.com")
            ]))
            return
        } else if miniAppId.starts(with: "21f") {
            completionHandler(.success([
                MAContact(id: "1", name: "Steve Jops", email: "steve@appl.com")
            ]))
            return
        }
        completionHandler(.failure(.unknownError(domain: "", code: 0, description: "no contacts")))
        return
    }

    func getPoints(completionHandler: @escaping (Result<MAPoints, MASDKPointError>) -> Void) {
        completionHandler(.success(MAPoints(standard: 0, term: 0, cash: 0)))
    }

    func requestCustomPermissions(permissions: [MASDKCustomPermissionModel], miniAppTitle: String, completionHandler: @escaping (Result<[MASDKCustomPermissionModel], MASDKCustomPermissionError>) -> Void) {
        completionHandler(.failure(.userDenied))
    }
}
