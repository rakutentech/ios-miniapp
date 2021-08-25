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
    let metaDataApi: MetaDataAPI
    var environment: Environment
    private var previewPath: String {
        self.environment.isPreviewMode ? "preview" : ""
    }
    weak var delegate: MiniAppDownloaderProtocol?

    convenience init(baseUrl: String? = nil, rasProjectId: String? = nil, subscriptionKey: String? = nil, hostAppVersion: String? = nil, isPreviewMode: Bool? = false) {
        self.init(with: MiniAppSdkConfig(baseUrl: baseUrl, rasProjectId: rasProjectId, subscriptionKey: subscriptionKey, hostAppVersion: hostAppVersion, isPreviewMode: isPreviewMode))
    }

    init(with config: MiniAppSdkConfig) {
        self.environment = Environment(with: config)
        self.listingApi = ListingApi(environment: self.environment)
        self.manifestApi = ManifestApi(environment: self.environment)
        self.downloadApi = DownloadApi(environment: self.environment)
        self.metaDataApi = MetaDataAPI(with: self.environment)
    }

    func updateEnvironment(with config: MiniAppSdkConfig?) {
        self.environment.customUrl = config?.baseUrl
        self.environment.customProjectId = config?.rasProjectId
        self.environment.customSubscriptionKey = config?.subscriptionKey
        self.environment.customAppVersion = config?.hostAppVersion
        self.environment.customIsPreviewMode = config?.isPreviewMode
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

    func getMiniAppMetaData(appId: String,
                            versionId: String,
                            completionHandler: @escaping (Result<ResponseData, Error>) -> Void) {
        guard let urlRequest = self.metaDataApi.createURLRequest(appId: appId, versionId: versionId, testPath: self.previewPath) else {
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

    func requestFromServer(urlRequest: URLRequest, retry500: Int = 0, completionHandler: @escaping (Result<ResponseData, Error>) -> Void) {
        return session.startDataTask(with: urlRequest) { (result) in
            switch result {
            case .success(let responseData):
                let statusCode = responseData.httpResponse.statusCode
                let logIcon = statusCode < 300 ? "🟢" : "🟠"
                MiniAppLogger.d("[\(statusCode)] urlRequest \(urlRequest.url?.absoluteString ?? "-") : \n\(String(data: responseData.data, encoding: .utf8) ?? "Empty response")", logIcon)

                if !(200...299).contains(statusCode) {
                    let failure = self.handleHttpResponse(responseData: responseData.data, httpResponse: responseData.httpResponse)
                    if statusCode >= 500, retry500 < 5 {
                        let backOff = 2.0
                        let retry = retry500 + 1
                        let waitTime = 0.5*pow(backOff, Double(retry500))
                        let failureMessage = "\(failure.localizedDescription) : Attempt [\(retry)]."
                        MiniAppLogger.d("\(failureMessage) \nRetry in \(waitTime)s", "🟠")
                        return DispatchQueue.main.asyncAfter(deadline: .now() + waitTime) {
                            self.requestFromServer(urlRequest: urlRequest, retry500: retry, completionHandler: completionHandler)
                        }
                    }
                    MiniAppLogger.d("\(failure.localizedDescription)", "🔴")
                    return completionHandler(.failure(failure))
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
