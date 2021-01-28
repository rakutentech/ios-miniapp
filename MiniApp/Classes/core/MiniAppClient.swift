import ZIPFoundation

protocol SessionProtocol {
    func startDataTask(
        with request: URLRequest,
        completionHandler: @escaping (Result<ResponseData, Error>) -> Void
    )
    func startDownloadTask(downloadUrl: URL)
}

internal class MiniAppClient: NSObject, URLSessionDownloadDelegate {

    let listingApi: ListingApi
    let manifestApi: ManifestApi
    let downloadApi: DownloadApi
    var environment: Environment
    private var previewPath: String {
        self.environment.isPreviewMode ? "preview" : ""
    }
    weak var delegate: MiniAppDownloaderProtocol?

    @available(*, deprecated, renamed: "init(baseUrl:rasProjectId:subscriptionKey:hostAppVersion:)")
    convenience init(baseUrl: String? = nil, rasAppId: String, subscriptionKey: String, hostAppVersion: String? = nil) {
        self.init(baseUrl: baseUrl, rasAppId: rasAppId, subscriptionKey: subscriptionKey, hostAppVersion: hostAppVersion, isTestMode: false)
    }

    @available(*, deprecated, renamed: "init(baseUrl:rasProjectId:subscriptionKey:hostAppVersion:isPreviewMode:)")
    convenience init(baseUrl: String? = nil, rasAppId: String, subscriptionKey: String, hostAppVersion: String? = nil, isTestMode: Bool? = false) {
        self.init(with: MiniAppSdkConfig(baseUrl: baseUrl, rasAppId: rasAppId, subscriptionKey: subscriptionKey, hostAppVersion: hostAppVersion, isTestMode: isTestMode))
    }

    convenience init(baseUrl: String? = nil, rasProjectId: String? = nil, subscriptionKey: String? = nil, hostAppVersion: String? = nil, isPreviewMode: Bool? = true) {
        self.init(with: MiniAppSdkConfig(baseUrl: baseUrl, rasProjectId: rasProjectId, subscriptionKey: subscriptionKey, hostAppVersion: hostAppVersion, isPreviewMode: isPreviewMode))
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
        self.environment.customProjectId = config?.rasProjectId
        self.environment.customSubscriptionKey = config?.subscriptionKey
        self.environment.customAppVersion = config?.hostAppVersion
        self.environment.customIsPreviewMode = config?.isPreviewMode ?? true
    }

    lazy var session: SessionProtocol = {
        return URLSession(configuration: .default, delegate: self, delegateQueue: nil)
    }()

    func getMiniAppsList(completionHandler: @escaping (Result<ResponseData, Error>) -> Void) {

        guard let urlRequest = self.listingApi.createURLRequest(testPath: self.previewPath) else {
            return completionHandler(.failure(NSError.invalidURLError()))
        }
        return requestFromServer(urlRequest: urlRequest, completionHandler: completionHandler)
    }

    func getMiniApp(_ miniAppId: String, completionHandler: @escaping (Result<ResponseData, Error>) -> Void) {

        guard let urlRequest = self.listingApi.createURLRequest(for: miniAppId, testPath: self.previewPath) else {
            return completionHandler(.failure(NSError.invalidURLError()))
        }
        return requestFromServer(urlRequest: urlRequest, completionHandler: completionHandler)
    }

    func getAppManifest(appId: String,
                        versionId: String,
                        completionHandler: @escaping (Result<ResponseData, Error>) -> Void) {

        guard let urlRequest = self.manifestApi.createURLRequest(appId: appId, versionId: versionId, testPath: self.previewPath) else {
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
                let statusCode = responseData.httpResponse.statusCode
                MiniAppLogger.d("[\(statusCode)] urlRequest \(urlRequest.url?.absoluteString ?? "-") : \n\(String(data: responseData.data, encoding: .utf8) ?? "Empty response")", "🟢")

                if !(200...299).contains(statusCode) {
                    return completionHandler(.failure(
                        self.handleHttpResponse(responseData: responseData.data,
                                                httpResponse: responseData.httpResponse)
                        ))
                }
                return completionHandler(.success(ResponseData(responseData.data,
                                                               responseData.httpResponse)))
            case .failure(let error):
                MiniAppLogger.d("urlRequest \(urlRequest.url?.absoluteString ?? "-") : Failure", "🔴")
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
