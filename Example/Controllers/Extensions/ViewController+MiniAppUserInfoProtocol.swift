import Foundation
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
        guard let downloadUrl = URL(string: url) else {
            completionHandler(.failure(.invalidUrl))
            return
        }
        download(url: downloadUrl.absoluteString, headers: headers) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    guard
                        let savedUrl = self.saveTemporaryFile(data: data,
                                                              resourceName: fileName.stringByDeletingPathExtension,
                                                              fileExtension: fileName.pathExtension)
                    else {
                        completionHandler(.failure(MASDKDownloadFileError.saveTemporarilyFailed))
                        return
                    }
                    let activityVc = MiniAppActivityController(activityItems: [savedUrl], applicationActivities: nil)
                    self.presentedViewController?.present(activityVc, animated: true, completion: nil)
                    completionHandler(.success(fileName))
                case .failure(let error):
                    completionHandler(.failure(error))
                }
            }
        }
    }

    func download(url: String, headers: DownloadHeaders, completion: ((Result<Data, MASDKDownloadFileError>) -> Void)? = nil) {
        if Base64UriHelper.isBase64String(text: url) {
            guard
                let data = Base64UriHelper.decodeBase64String(text: url)
            else {
                completion?(.failure(MASDKDownloadFileError.invalidUrl))
                return
            }

            completion?(.success(data))
        } else {
            guard
                let url = URL(string: url)
            else {
                completion?(.failure(MASDKDownloadFileError.invalidUrl))
                return
            }
            let session = URLSession.shared
            var request = URLRequest(url: url)
            headers.forEach({ request.addValue($0.value, forHTTPHeaderField: $0.key) })
            let task = session.downloadTask(with: request) { (tempFileUrl, response, error) in
                if let error = error {
                    completion?(.failure(MASDKDownloadFileError.downloadFailed(code: -1, reason: error.localizedDescription)))
                    return
                }
                guard
                    let statusCode = (response as? HTTPURLResponse)?.statusCode
                else {
                    completion?(.failure(MASDKDownloadFileError.downloadFailed(code: -1, reason: "no status code")))
                    return
                }
                guard
                    statusCode >= 200 && statusCode <= 300
                else {
                    let reason = HTTPURLResponse.localizedString(forStatusCode: statusCode)
                    completion?(.failure(MASDKDownloadFileError.downloadHttpError(code: statusCode, reason: reason)))
                    return
                }
                guard
                    let tempFileUrl = tempFileUrl,
                        let data = try? Data(contentsOf: tempFileUrl)
                else {
                    completion?(.failure(MASDKDownloadFileError.downloadFailed(code: -1, reason: "could not load local data")))
                    return
                }

                completion?(.success(data))
            }
            task.resume()
        }
    }

    func saveTemporaryFile(data: Data, resourceName: String, fileExtension: String) -> URL? {
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
