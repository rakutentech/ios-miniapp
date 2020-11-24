@testable import MiniApp
import WebKit

// swiftlint:disable file_length
class MockAPIClient: MiniAppClient {
    var data: Data?
    var manifestData: Data?
    var error: Error?
    var request: URLRequest?
    var zipFile: String?
    var headers: [String: String]?

    init() {
        let bundle = MockBundle()
        super.init(with:
                MiniAppSdkConfig(
                    baseUrl: bundle.mockEndpoint,
                    rasAppId: bundle.mockAppId,
                    subscriptionKey: bundle.mockSubscriptionKey,
                    hostAppVersion: bundle.mockHostAppUserAgentInfo,
                    isTestMode: bundle.mockTestMode
                )
        )
    }

    override func getMiniAppsList(completionHandler: @escaping (Result<ResponseData, Error>) -> Void) {
        guard let urlRequest = self.listingApi.createURLRequest() else {
            return completionHandler(.failure(NSError.invalidURLError()))
        }

        guard let data = data else {
            return completionHandler(.failure(error ?? NSError(domain: "Test", code: 0, userInfo: nil)))
        }

        guard let url = urlRequest.url else {
            return
        }

        self.request = urlRequest
        if let httpResponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion: "1.1", headerFields: headers) {
            return completionHandler(.success(ResponseData(data, httpResponse)))
        }
    }

    override func getMiniApp(_ miniAppId: String, completionHandler: @escaping (Result<ResponseData, Error>) -> Void) {
        guard let urlRequest = self.listingApi.createURLRequest() else {
            return completionHandler(.failure(NSError.invalidURLError()))
        }

        guard let data = data else {
            return completionHandler(.failure(error ?? NSError(domain: "Test", code: 0, userInfo: nil)))
        }

        guard let url = urlRequest.url else {
            return
        }

        self.request = urlRequest
        if let httpResponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion: "1.1", headerFields: headers) {
            return completionHandler(.success(ResponseData(data, httpResponse)))
        }
    }

    override func getAppManifest(appId: String, versionId: String, completionHandler: @escaping (Result<ResponseData, Error>) -> Void) {
        guard let urlRequest = self.manifestApi.createURLRequest(appId: appId, versionId: versionId) else {
            return completionHandler(.failure(NSError.invalidURLError()))
        }

        guard let responseData = manifestData ?? data else {
            return completionHandler(.failure(error ?? NSError(domain: "Test", code: 0, userInfo: nil)))
        }

        guard let url = urlRequest.url else {
            return
        }

        self.request = urlRequest
        if let httpResponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion: "1.1", headerFields: headers) {
            return completionHandler(.success(ResponseData(responseData, httpResponse)))
        }
    }

    override func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let destinationURL = downloadTask.currentRequest?.url?.absoluteString else {
            delegate?.downloadFileTaskCompleted(url: "", error: NSError.downloadingFailed())
            return
        }
        guard let fileName = downloadTask.currentRequest?.url?.lastPathComponent else {
            delegate?.downloadFileTaskCompleted(url: "", error: NSError.downloadingFailed())
            return
        }

        let mockSourceFileURL: URL
        if let zip = zipFile {
            mockSourceFileURL = URL(fileURLWithPath: zip)
        } else if let file = MockFile.createTestFile(fileName: fileName) {
            mockSourceFileURL = file
        } else {
            delegate?.downloadFileTaskCompleted(url: "", error: NSError.downloadingFailed())
            return
        }
        delegate?.fileDownloaded(at: mockSourceFileURL, downloadedURL: destinationURL)
    }

    override func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let url = task.currentRequest?.url?.absoluteString else {
            delegate?.downloadFileTaskCompleted(url: "", error: NSError.downloadingFailed())
            return
        }
        delegate?.downloadFileTaskCompleted(url: url, error: error)
    }
}

class MockMiniAppInfoFetcher: MiniAppInfoFetcher {
    var data: Data?
    var error: Error?

    override func getInfo(miniAppId: String, miniAppVersion: String? = nil, apiClient: MiniAppClient, completionHandler: @escaping (Result<MiniAppInfo, Error>) -> Void) {

        if error != nil {
            return completionHandler(.failure(error ?? NSError(domain: "Test", code: 0, userInfo: nil)))
        }
        apiClient.getMiniApp(miniAppId) { (result) in
            switch result {
            case .success(let responseData):
                guard let decodeResponse = ResponseDecoder.decode(decodeType: Array<MiniAppInfo>.self, data: responseData.data), let miniApp = decodeResponse.first else {
                    return completionHandler(.failure(NSError.invalidResponseData()))
                }
                return completionHandler(.success(miniApp))

            case .failure(let error):
                return completionHandler(.failure(error))
            }
        }
    }
}

class MockManifestDownloader: ManifestDownloader {
    var data: Data?
    var error: Error?
    var request: URLRequest?
    var headers: [String: String]?

    override func fetchManifest(apiClient: MiniAppClient, appId: String, versionId: String, completionHandler: @escaping (Result<ManifestResponse, Error>) -> Void) {

        if error != nil {
            return completionHandler(.failure(error ?? NSError(domain: "Test", code: 0, userInfo: nil)))
        }

        apiClient.getAppManifest(appId: appId, versionId: versionId) { (result) in
            switch result {
            case .success(let responseData):
                guard let decodeResponse = ResponseDecoder.decode(decodeType: ManifestResponse.self, data: responseData.data) else {
                    return completionHandler(.failure(NSError.invalidResponseData()))
                }
                return completionHandler(.success(decodeResponse))
            case .failure(let error):
                return completionHandler(.failure(error))
            }
        }
    }
}

class MockBundle: EnvironmentProtocol {
    var valueNotFound: String {
        return mockValueNotFound ?? ""
    }

    var mockValueNotFound: String?
    var mockAppId: String?
    var mockProjectId: String?
    var mockSubscriptionKey: String?
    var mockAppVersion: String?
    var mockEndpoint: String? = "https://www.example.com/"
    var mockTestMode: Bool?
    var mockPreviewMode: Bool?
    var mockHostAppUserAgentInfo: String?

    func bool(for key: String) -> Bool? {
        switch key {
        case "RMAIsTestMode":
            return mockTestMode
        case "RMAIsPreviewMode":
            return mockPreviewMode
        default:
            return nil
        }
    }

    func value(for key: String) -> String? {
        switch key {
        case "RASApplicationIdentifier":
            return mockAppId
        case "RASProjectId":
            return mockProjectId
        case "RASProjectSubscriptionKey":
            return mockSubscriptionKey
        case "CFBundleShortVersionString":
            return mockAppVersion
        case "RMAAPIEndpoint":
            return mockEndpoint
        case "RMAHostAppUserAgentInfo":
            return mockHostAppUserAgentInfo
        default:
            return nil
        }
    }
}

class MockFile {

    public class func createTestFile(fileName: String) -> URL? {
        let tempDirectory = NSTemporaryDirectory()
        let rakutenText: Data? = "Rakuten".data(using: .utf8)
        guard let fullURL = NSURL.fileURL(withPathComponents: [tempDirectory, fileName]) else {
            return nil
        }
        FileManager.default.createFile(atPath: fullURL.path, contents: rakutenText, attributes: nil)
        return fullURL
    }
}

class MockMessageInterface: MiniAppMessageDelegate {
    var mockUniqueId: Bool = false
    var locationAllowed: Bool = false
    var customPermissions: Bool = false
    var permissionError: MASDKPermissionError?
    var customPermissionError: MASDKCustomPermissionError?
    var userSettingsAllowed: Bool = false
    var mockUserName: String? = ""
    var mockProfilePhoto: String? = ""
    var messageContentAllowed: Bool = false
    var mockAccessToken = false

    func shareContent(info: MiniAppShareContent, completionHandler: @escaping (Result<MASDKProtocolResponse, Error>) -> Void) {
        if messageContentAllowed {
            completionHandler(.success(.success))
        } else {
            completionHandler(.failure(NSError(domain: "ShareContentError", code: 0, userInfo: nil)))
        }
    }

    func getUniqueId() -> String {
        if mockUniqueId {
            return ""
        } else {
            guard let deviceId = UIDevice.current.identifierForVendor?.uuidString else {
                return ""
            }
            return deviceId
        }
    }

    func requestPermission(permissionType: MiniAppPermissionType, completionHandler: @escaping (Result<MASDKPermissionResponse, MASDKPermissionError>) -> Void) {
        if locationAllowed {
            completionHandler(.success(.allowed))
        } else {
            if permissionError != nil {
                completionHandler(.failure(permissionError!))
                return
            }
            completionHandler(.failure(.denied))
        }
    }

    func requestCustomPermissions(permissions: [MASDKCustomPermissionModel],
                                  miniAppTitle: String,
                                  completionHandler: @escaping (Result<[MASDKCustomPermissionModel], MASDKCustomPermissionError>) -> Void) {
        if customPermissions {
            completionHandler(.success(permissions))
        } else {
            if customPermissionError != nil {
                completionHandler(.failure(customPermissionError!))
                return
            }
            completionHandler(.failure(.unknownError))
        }
    }

    func getUserName() -> String? {
        return mockUserName
    }

    func getProfilePhoto() -> String? {
        return mockProfilePhoto
    }

    func getAccessToken(miniAppId: String, completionHandler: @escaping (Result<MATokenInfo, MASDKCustomPermissionError>) -> Void) {
        if mockAccessToken {
            completionHandler(.success(MATokenInfo(accessToken: "MOCK_ACCESS_TOKEN", expirationDate: Date())))
        } else {
            completionHandler(.failure(.unknownError))
        }
    }
}

var mockMiniAppInfo: MiniAppInfo {
    let mockVersion = Version(versionTag: "Dev", versionId: "ver-id-test")
    let info = MiniAppInfo.init(id: "app-id-test", displayName: "Mini App Title", icon: URL(string: "https://www.example.com/icon.png")!, version: mockVersion)
    return info
}

class MockWKScriptMessage: WKScriptMessage {

    let mockBody: Any
    let mockName: String

    init(name: String, body: Any) {
        mockName = name
        mockBody = body
    }

    override var body: Any {
        return mockBody
    }

    override var name: String {
        return mockName
    }
}

class MockMiniAppCallbackProtocol: MiniAppCallbackDelegate {
    var messageId: String?
    var response: String?
    var errorMessage: String?

    func didReceiveScriptMessageResponse(messageId: String, response: String) {
        self.messageId = messageId
        self.response = response
    }

    func didReceiveScriptMessageError(messageId: String, errorMessage: String) {
        self.messageId = messageId
        self.errorMessage = errorMessage
    }

    func didOrientationChanged(orientation: UIInterfaceOrientationMask) {
    }
}

class MockNavigationView: UIView, MiniAppNavigationDelegate {
    func miniAppNavigation(shouldOpen url: URL, with externalLinkResponseHandler: @escaping MiniAppNavigationResponseHandler) {
        externalLinkResponseHandler(url)
    }

    weak var delegate: MiniAppNavigationBarDelegate?
    var hasReceivedBack: Bool = false
    var hasReceivedForward: Bool = true

    func actionGoBack() {
        delegate?.miniAppNavigationBar(didTriggerAction: .back)
    }

    func actionGoForward() {
        delegate?.miniAppNavigationBar(didTriggerAction: .forward)
    }

    func miniAppNavigation(delegate: MiniAppNavigationBarDelegate) {
        self.delegate = delegate
    }

    func miniAppNavigation(canUse actions: [MiniAppNavigationAction]) {
        hasReceivedForward = false
        hasReceivedBack = false
        actions.forEach { (action) in
            switch action {
            case .back:
                hasReceivedBack = true
            case .forward:
                hasReceivedForward = true
            }
        }
    }
}

class MockNavigationWebView: MiniAppWebView {
    override var canGoBack: Bool {
        true
    }
    override var canGoForward: Bool {
        true
    }
    override func goBack() -> WKNavigation? {
        return nil
    }
    override func goForward() -> WKNavigation? {
        return nil
    }
}

/// Method to delete the Mini App directory which was created for Mock testing
/// - Parameters:
///   - appId: Mini App ID
func deleteMockMiniApp(appId: String, versionId: String) {
    try? FileManager.default.removeItem(at: FileManager.getMiniAppDirectory(with: appId))
}

func deleteStatusPreferences() {
    UserDefaults.standard.removePersistentDomain(forName: "com.rakuten.tech.mobile.miniapp")
}

func updateCustomPermissionStatus(miniAppId: String, permissionType: MiniAppCustomPermissionType, status: MiniAppCustomPermissionGrantedStatus) {
    MiniApp.shared().setCustomPermissions(forMiniApp: miniAppId,
        permissionList: [MASDKCustomPermissionModel(
            permissionName: permissionType,
            isPermissionGranted: status,
            permissionRequestDescription: "")])
}

func decodeMiniAppError(message: String?) -> MiniAppErrorDetail? {
    guard let errorData = message?.data(using: .utf8) else {
        return nil
    }
    guard let errorMessage = ResponseDecoder.decode(decodeType: MiniAppErrorDetail.self, data: errorData) else {
        return nil
    }
    return errorMessage
}

extension UIImage {
    func hasAlpha() -> Bool {
        let noAlphaCases: [CGImageAlphaInfo] = [.none, .noneSkipLast, .noneSkipFirst]
        if let alphaInfo = cgImage?.alphaInfo {
            return !noAlphaCases.contains(alphaInfo)
        } else {
            return false
        }
    }

    func dataURI() -> String? {
        var mimeType: String = ""
        var imageData: Data
        if hasAlpha(), let png = pngData() {
            imageData = png
            mimeType = "image/png"
        } else if let jpg = jpegData(compressionQuality: 1.0) {
            imageData = jpg
            mimeType = "image/jpeg"
        } else {
            return nil
        }

        return "data:\(mimeType);base64,\(imageData.base64EncodedString())"
    }
}
