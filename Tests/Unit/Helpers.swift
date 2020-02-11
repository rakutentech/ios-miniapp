@testable import MiniApp

class MockAPIClient: MiniAppClient {
    var data: Data?
    var error: Error?
    var request: URLRequest?
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
            return  completionHandler(.success(ResponseData(data, httpResponse)))
        }
    }

    override func getAppManifest(appId: String, versionId: String, completionHandler: @escaping (Result<ResponseData, Error>) -> Void) {
        guard let urlRequest = self.manifestApi.createURLRequest(appId: appId, versionId: versionId) else {
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
            return  completionHandler(.success(ResponseData(data, httpResponse)))
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
