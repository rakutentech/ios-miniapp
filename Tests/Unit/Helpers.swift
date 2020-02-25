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

    override func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let destinationURL = downloadTask.currentRequest?.url?.absoluteString else {
            delegate?.downloadCompleted(url: "", error: NSError.downloadingFailed())
            return
        }
        guard let fileName = downloadTask.currentRequest?.url?.lastPathComponent else {
            delegate?.downloadCompleted(url: "", error: NSError.downloadingFailed())
            return
        }
        guard let mockSourceFileURL =  MockFile.createTestFile(fileName: fileName) else {
            delegate?.downloadCompleted(url: "", error: NSError.downloadingFailed())
            return
        }
        delegate?.fileDownloaded(sourcePath: mockSourceFileURL, destinationPath: destinationURL)
    }

    override func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let url = task.currentRequest?.url?.absoluteString else {
            delegate?.downloadCompleted(url: "", error: NSError.downloadingFailed())
            return
        }
        delegate?.downloadCompleted(url: url, error: error)
    }}

class MockManifestDownloader: ManifestDownloader {
    var data: Data?
    var error: Error?
    var request: URLRequest?
    var headers: [String: String]?

    override func fetchManifest(apiClient: MiniAppClient, appId: String, versionId: String, completionHandler: @escaping (Result<ManifestResponse, Error>) -> Void) {

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
