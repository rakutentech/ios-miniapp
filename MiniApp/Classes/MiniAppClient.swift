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
    let environment: Environment

    override init() {
        self.environment = Environment()
        self.listingApi = ListingApi(environment: self.environment)
        self.manifestApi = ManifestApi(environment: self.environment)
        self.downloadApi = DownloadApi(environment: self.environment)
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
        guard let errorModel = ResponseDecoder.decode(decodeType: ErrorData.self,
                                                      data: responseData) else {
            return NSError.unknownServerError(httpResponse: httpResponse)
        }
        return NSError.serverError(code: errorModel.code, message: errorModel.message)
    }

    // Saving the file - Storage
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {

    }
}
