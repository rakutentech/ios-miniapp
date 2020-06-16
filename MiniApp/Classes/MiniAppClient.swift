import ZIPFoundation

protocol SessionProtocol {
    func startDataTask(
        with request: URLRequest,
        completionHandler: @escaping (Result<ResponseData, Error>) -> Void
    )
    func startDownloadTask(downloadUrl: URL)
}

class MiniAppClient: NSObject, URLSessionDownloadDelegate {

    let listingApi: ListingApi
    let manifestApi: ManifestApi
    let downloadApi: DownloadApi
    var environment: Environment
    weak var delegate: MiniAppDownloaderProtocol?

    convenience override init() {
        self.init(baseUrl: nil, rasAppId: nil, subscriptionKey: nil, hostAppVersion: nil)
    }

    convenience init(baseUrl: String? = nil, rasAppId: String? = nil, subscriptionKey: String? = nil, hostAppVersion: String? = nil) {
        self.init(with: MiniAppSdkConfig(baseUrl: baseUrl, rasAppId: rasAppId, subscriptionKey: subscriptionKey, hostAppVersion: hostAppVersion))
    }

    init(with config: MiniAppSdkConfig) {
        self.environment = Environment(with: config)
        self.listingApi = ListingApi(environment: self.environment)
        self.manifestApi = ManifestApi(environment: self.environment)
        self.downloadApi = DownloadApi(environment: self.environment)
    }

    func updateEnvironment(with config: MiniAppSdkConfig?) {
        self.environment.customUrl = config?.baseUrl
        self.environment.customAppId = config?.rasAppId
        self.environment.customSubscriptionKey = config?.subscriptionKey
        self.environment.customAppVersion = config?.hostAppVersion
    }

    lazy var session: SessionProtocol = {
        return URLSession(configuration: .default, delegate: self, delegateQueue: nil)
    }()

    func getMiniAppsList(completionHandler: @escaping (Result<ResponseData, Error>) -> Void) {

        guard let urlRequest = self.listingApi.createURLRequest() else {
            return completionHandler(.failure(NSError.invalidURLError()))
        }
        return requestFromServer(urlRequest: urlRequest, completionHandler: completionHandler)
    }

    func getMiniApp(_ miniAppId: String, completionHandler: @escaping (Result<ResponseData, Error>) -> Void) {

        guard let urlRequest = self.listingApi.createURLRequest(for: miniAppId) else {
            return completionHandler(.failure(NSError.invalidURLError()))
        }
        return requestFromServer(urlRequest: urlRequest, completionHandler: completionHandler)
    }

    func getAppManifest(appId: String,
                        versionId: String,
                        completionHandler: @escaping (Result<ResponseData, Error>) -> Void) {

        guard let urlRequest = self.manifestApi.createURLRequest(appId: appId, versionId: versionId) else {
            return completionHandler(.failure(NSError.invalidURLError()))
        }
        return requestFromServer(urlRequest: urlRequest, completionHandler: completionHandler)
    }

    func download(url: String) {
        guard let url = self.downloadApi.createURLFromString(urlString: url) else {
            return
        }
        self.session.startDownloadTask(downloadUrl: url)
    }

    func requestFromServer(urlRequest: URLRequest, completionHandler: @escaping (Result<ResponseData, Error>) -> Void) {
        return session.startDataTask(with: urlRequest) { (result) in
            switch result {
            case .success(let responseData):
                if !(200...299).contains(responseData.httpResponse.statusCode) {
                    return completionHandler(.failure(
                        self.handleHttpResponse(responseData: responseData.data,
                                                httpResponse: responseData.httpResponse)
                    ))
                }
                return completionHandler(.success(ResponseData(responseData.data,
                                                               responseData.httpResponse)))
            case .failure(let error):
                return completionHandler(.failure(error))
            }
        }
    }

    func handleHttpResponse(responseData: Data, httpResponse: HTTPURLResponse) -> NSError {
        let code = httpResponse.statusCode
        var message: String

        switch code {
        case 401, 403:
            guard let errorModel = ResponseDecoder.decode(decodeType: UnauthorizedData.self,
                                                          data: responseData) else {
                return NSError.unknownServerError(httpResponse: httpResponse)
            }
            message = "\(errorModel.error): \(errorModel.errorDescription)"
        default:
            guard let errorModel = ResponseDecoder.decode(decodeType: ErrorData.self,
                                                          data: responseData) else {
                return NSError.unknownServerError(httpResponse: httpResponse)
            }
            message = errorModel.message
        }

        return NSError.serverError(code: code, message: message)
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let destinationURL = downloadTask.currentRequest?.url?.absoluteString else {
            delegate?.downloadFileTaskCompleted(url: "", error: NSError.downloadingFailed())
            return
        }
        delegate?.fileDownloaded(at: location, downloadedURL: destinationURL)
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let url = task.currentRequest?.url?.absoluteString else {
            delegate?.downloadFileTaskCompleted(url: "", error: NSError.downloadingFailed())
            return
        }
        delegate?.downloadFileTaskCompleted(url: url, error: error)
    }
}
