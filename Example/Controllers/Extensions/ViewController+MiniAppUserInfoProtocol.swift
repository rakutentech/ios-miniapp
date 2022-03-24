import MiniApp
import UIKit

extension ViewController: MiniAppUserInfoDelegate {

    func getUserName(completionHandler: @escaping (Result<String?, MASDKError>) -> Void) {
        guard let userProfile = getProfileSettings(), let userName = userProfile.displayName else {
            return completionHandler(.failure(.unknownError(domain: "Unknown Error", code: 1, description: "Failed to retrieve User name")))
        }
        completionHandler(.success(userName))
    }

    func getProfilePhoto(completionHandler: @escaping (Result<String?, MASDKError>) -> Void) {
        guard let userProfile = getProfileSettings(), let userProfilePhoto = userProfile.profileImageURI else {
            return completionHandler(.failure(.unknownError(domain: "Unknown Error", code: 1, description: "Failed to retrieve Profile photo")))
        }
        completionHandler(.success(userProfilePhoto))
    }

    func getContacts(completionHandler: @escaping (Result<[MAContact]?, MASDKError>) -> Void) {
        if let userProfile = getProfileSettings(), let contactsList = userProfile.contactList {
            return completionHandler(.success(contactsList))
        }
        completionHandler(.failure(.unknownError(domain: "Unknown Error", code: 1, description: "Failed to retrieve contacts list")))
    }

    func getAccessToken(miniAppId: String,
                        scopes: MASDKAccessTokenScopes,
                        completionHandler: @escaping (Result<MATokenInfo, MASDKAccessTokenError>) -> Void) {
        if let errorMode = QASettingsTableViewController.accessTokenErrorType() {
            let message = QASettingsTableViewController.accessTokenErrorMessage()
            switch errorMode {
            case .AUTHORIZATION:
                return completionHandler(.failure(.authorizationFailureError(description: "authorizationFailureError" + ( (message != nil) ? ": " + message! : "" ))))
            default:
                return completionHandler(.failure(.error(description: "Other error" + ( (message != nil) ? ": " + message! : "" ))))
            }
        }
        var resultToken = "ACCESS_TOKEN"
        var resultDate = Date()
        let resultScopes = scopes

        if let tokenInfo = getTokenInfo() {
           resultToken = tokenInfo.tokenString
           resultDate = tokenInfo.expiryDate
        }
        completionHandler(.success(.init(accessToken: resultToken, expirationDate: resultDate, scopes: resultScopes)))
    }

    func getPoints(completionHandler: @escaping (Result<MAPoints, MASDKPointError>) -> Void) {
        if let pointsModel = getUserPoints() {
            let maPointsModel = MAPoints(
                standard: pointsModel.standardPoints ?? 0,
                term: pointsModel.termPoints ?? 0,
                cash: pointsModel.cashPoints ?? 0
            )
            completionHandler(.success(maPointsModel)
            )
        }
        completionHandler(.success(MAPoints(standard: 0, term: 0, cash: 0)))
    }

    func downloadFile(fileName: String, url: String, headers: DownloadHeaders, completionHandler: @escaping (Result<String, MASDKDownloadFileError>) -> Void) {
        let fileNameParts = fileName.split(separator: ".")
        let fileName = String(fileNameParts[0])
        let fileExtension = String(fileNameParts[1])
        guard
            let url = URL(string: url)
        else {
            completionHandler(.failure(MASDKDownloadFileError.invalidUrl))
            return
        }
        guard
            let data = try? Data(contentsOf: url)
        else {
            completionHandler(.failure(MASDKDownloadFileError.downloadFailed))
            return
        }
        guard
            let savedUrl = saveTemporaryFile(data: data, resourceName: fileName, fileExtension: fileExtension)
        else {
            completionHandler(.failure(MASDKDownloadFileError.saveTemporarilyFailed))
            return
        }
        // share temporarily saved file
        let activityVc = UIActivityViewController(activityItems: [savedUrl], applicationActivities: nil)
        self.presentedViewController?.present(activityVc, animated: true, completion: nil)
        completionHandler(.success(fileName))
    }

    public func saveTemporaryFile(data: Data, resourceName: String, fileExtension: String) -> URL? {
        let tempDirectoryURL = URL.init(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        let targetURL = tempDirectoryURL.appendingPathComponent("\(resourceName).\(fileExtension)")
        do {
            try data.write(to: targetURL, options: .atomic)
            return targetURL
        } catch let error {
            print("Unable to copy file: \(error)")
        }
        return nil
    }
}
