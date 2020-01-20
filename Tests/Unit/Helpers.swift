@testable import MiniApp

class MockAPIClient: MiniAppClient {
    var data: Data?
    var error: Error?
    var request: URLRequest?
    var headers: [String: String]?

    override func requestFromServer(request: URLRequest, completionHandler: @escaping (Result<ResponseData, Error>) -> Void) {
        self.request = request

        guard let data = data, let url = request.url else {
            return completionHandler(.failure(error ?? NSError(domain: "Test", code: 0, userInfo: nil)))
        }

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
        case "RMAConfigAPIEndpoint":
            return mockEndpoint
        default:
            return nil
        }
    }

}
