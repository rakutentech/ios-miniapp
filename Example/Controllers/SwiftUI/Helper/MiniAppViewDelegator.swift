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

    func getUserName(completionHandler: @escaping (Result<String?, MASDKError>) -> Void) {
        completionHandler(.success(getProfileSettings()?.displayName))
    }

    func getProfilePhoto(completionHandler: @escaping (Result<String?, MASDKError>) -> Void) {
        completionHandler(.success(getProfileSettings()?.profileImageURI))
    }

    func getContacts(completionHandler: @escaping (Result<[MAContact]?, MASDKError>) -> Void) {
        completionHandler(.success(getContactList()))
        return
    }

    func getPoints(completionHandler: @escaping (Result<MAPoints, MASDKPointError>) -> Void) {
        if let points = getUserPoints() {
            completionHandler(.success(
                MAPoints(
                    standard: points.standardPoints ?? 0,
                    term: points.termPoints ?? 0,
                    cash: points.cashPoints ?? 0
                )
            ))
        } else {
            completionHandler(.success(MAPoints(standard: 0, term: 0, cash: 0)))
        }
    }

    func requestCustomPermissions(permissions: [MASDKCustomPermissionModel], miniAppTitle: String, completionHandler: @escaping (Result<[MASDKCustomPermissionModel], MASDKCustomPermissionError>) -> Void) {
        completionHandler(.failure(.userDenied))
    }

    func getAccessToken(miniAppId: String, scopes: MASDKAccessTokenScopes, completionHandler: @escaping (Result<MATokenInfo, MASDKAccessTokenError>) -> Void) {
        if let info = getTokenInfo() {
            completionHandler(
                .success(
                    MATokenInfo(
                        accessToken: info.tokenString,
                        expirationDate: info.expiryDate,
                        scopes: MASDKAccessTokenScopes(audience: "rae", scopes: info.scopes ?? [])
                    )
                )
            )
        } else {
            completionHandler(.failure(.failedToConformToProtocol))
        }
    }
}
