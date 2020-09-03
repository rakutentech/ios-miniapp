@testable import MiniApp
import WebKit

class MockAPIClient: MiniAppClient {
    var data: Data?
    var manifestData: Data?
    var error: Error?
    var request: URLRequest?
    var zipFile: String?
    var headers: [String: String]?

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

    override func getInfo(miniAppId: String, apiClient: MiniAppClient, completionHandler: @escaping (Result<MiniAppInfo, Error>) -> Void) {

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
    var mockSubscriptionKey: String?
    var mockAppVersion: String?
    var mockEndpoint: String?
    var mockTestMode: Bool?
    var mockHostAppUserAgentInfo: String?

    func bool(for key: String) -> Bool? {
        switch key {
        case "RMAIsTestMode":
            return mockTestMode
        default:
            return nil
        }
    }

    func value(for key: String) -> String? {
        switch key {
        case "RASApplicationIdentifier":
            return mockAppId
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

class MockMessageInterface: MiniAppMessageProtocol {
    var mockUniqueId: Bool = false
    var locationAllowed: Bool = false
    var permissionError: Error?

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

    func requestPermission(permissionType: MiniAppPermissionType, completionHandler: @escaping (Result<String, Error>) -> Void) {
        if locationAllowed {
            completionHandler(.success("Allowed"))
        } else {
            if permissionError != nil {
                completionHandler(.failure(permissionError!))
                return
            }
            completionHandler(.failure(MiniAppPermissionResult.denied))
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

class MockMiniAppCallbackProtocol: MiniAppCallbackProtocol {
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
}

class MockNavigationView: UIView, MiniAppNavigationDelegate {
    func miniAppNavigation(shouldOpen url: URL, with jsonResponseHandler: @escaping (Codable) -> Void) {
        let jsonObject = MiniAppInfo(id: "miniAppNavigation", displayName: "miniAppNavigation", icon: URL(string: "http://www.example.com")!, version: Version(versionTag: "version", versionId: "id"))
        jsonResponseHandler(jsonObject)
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

func tapAlertButton(title: String, actions: [UIAlertAction]?) {
    typealias AlertHandler = @convention(block) (UIAlertAction) -> Void

    guard let action = actions?.first(where: {$0.title == title}), let block = action.value(forKey: "handler") else { return }
    let handler = unsafeBitCast(block as AnyObject, to: AlertHandler.self)
    handler(action)
}
