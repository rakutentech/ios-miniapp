import ZIPFoundation
import TrustKit

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
    let previewMiniappApi: PreviewMiniappAPI
    var environment: Environment
    var sslPinningConfig: MiniAppSSLConfig?
    internal var signatures: [String: (String, String)] = [:]
    internal var idsForUrls: [String: (String, String)] = [:]
    private var previewPath: String {
        environment.isPreviewMode ? "preview" : ""
    }
    private var isSignatureVerified: Bool = false
    private var isDownloadStatusUpdated: Bool = false

    weak var delegate: MiniAppDownloaderProtocol?

    typealias MAResponseDataHandler = (Result<ResponseData, MASDKError>) -> Void

    convenience init(baseUrl: String? = nil, sslKeyHash: MiniAppConfigSSLKeyHash? = nil, rasProjectId: String? = nil, subscriptionKey: String? = nil, hostAppVersion: String? = nil, isPreviewMode: Bool? = false) {
        self.init(with: MiniAppSdkConfig(
                baseUrl: baseUrl,
                rasProjectId: rasProjectId,
                subscriptionKey: subscriptionKey,
                hostAppVersion: hostAppVersion,
                isPreviewMode: isPreviewMode,
                sslKeyHash: sslKeyHash))
    }

    init(with config: MiniAppSdkConfig) {
        environment = Environment(with: config)
        listingApi = ListingApi(environment: environment)
        manifestApi = ManifestApi(environment: environment)
        downloadApi = DownloadApi(environment: environment)
        metaDataApi = MetaDataAPI(with: environment)
        previewMiniappApi = PreviewMiniappAPI(with: environment)
        super.init()
    }

    func updateSSLPinConfig() {
        if let sslPin = environment.sslKeyHash, sslPinningConfig == nil {
            // TrustKit wants a backup pin as a fallback in case the provided pin is failing challenge
            // https://github.com/datatheorem/TrustKit/issues/123
            let backupPin = environment.sslKeyHashBackup != sslPin && environment.sslKeyHashBackup != nil ? environment.sslKeyHashBackup! : "BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB="

            sslPinningConfig = MiniAppSSLConfig(with: environment.host, keyHashes: sslPin, backupPin)
            if let sslPinningConfig = sslPinningConfig?.dictionary() {
                TrustKit.initSharedInstance(withConfiguration: sslPinningConfig)
            }
        }
    }
    func updateEnvironment(with config: MiniAppSdkConfig?) {
        environment.customUrl = config?.baseUrl
        environment.customProjectId = config?.rasProjectId
        environment.customSubscriptionKey = config?.subscriptionKey
        environment.customAppVersion = config?.hostAppVersion
        environment.customIsPreviewMode = config?.isPreviewMode
        environment.customSignatureVerification = config?.requireMiniAppSignatureVerification
        environment.customSSLKeyHash = config?.sslKeyHash?.pin
        environment.customSSLKeyHashBackup = config?.sslKeyHash?.backupPin
        if sslPinningConfig == nil {
            updateSSLPinConfig()
        } else if
                let pins = sslPinningConfig?.domains[environment.host]?[kTSKPublicKeyHashes] as? [String],
                let sslKey = config?.sslKeyHash,
                sslKey.matches(pins) != nil {
            MiniAppLogger.e("You already set the SSL pinning configuration. iOS TLS cache would make pinning unstable.")
        }
    }

    lazy var session: SessionProtocol = {
        URLSession(configuration: .default, delegate: self, delegateQueue: nil)
    }()

    func getMiniAppsList(completionHandler: @escaping MAResponseDataHandler) {

        guard let urlRequest = self.listingApi.createURLRequest(testPath: self.previewPath) else {
            return completionHandler(.failure(.invalidURLError))
        }
        return requestDataFromServer(urlRequest: urlRequest, completionHandler: completionHandler)
    }

    func getMiniApp(_ miniAppId: String, completionHandler: @escaping MAResponseDataHandler) {

        guard let urlRequest = self.listingApi.createURLRequest(for: miniAppId, testPath: self.previewPath) else {
            return completionHandler(.failure(.invalidURLError))
        }
        return requestDataFromServer(urlRequest: urlRequest, completionHandler: completionHandler)
    }

    func getAppManifest(appId: String,
                        versionId: String,
                        completionHandler: @escaping MAResponseDataHandler) {

        guard let urlRequest = self.manifestApi.createURLRequest(appId: appId, versionId: versionId, testPath: self.previewPath) else {
            return completionHandler(.failure(.invalidURLError))
        }
        return requestDataFromServer(urlRequest: urlRequest) { [weak self] result in
            switch result {
            case .success(let data) :
                if let signature = data.httpResponse.value(forHTTPHeaderField: "Signature"), let signatureId = ResponseDecoder.decode(decodeType: ManifestResponse.self, data: data.data)?.publicKeyId {
                    MiniAppLogger.d(signature, "🖊️")
                    self?.signatures[versionId] = (signatureId, signature)
                } else {
                    fallthrough
                }
            case .failure :
                self?.signatures.removeValue(forKey: versionId)
            }
            completionHandler(result)
        }
    }

    func getMiniAppMetaData(appId: String,
                            versionId: String,
                            languageCode: String,
                            completionHandler: @escaping MAResponseDataHandler) {
        guard let urlRequest = self.metaDataApi.createURLRequest(appId: appId,
                                                                 versionId: versionId,
                                                                 testPath: self.previewPath,
                                                                 languageCode: languageCode) else {
            return completionHandler(.failure(.invalidURLError))
        }
        return requestDataFromServer(urlRequest: urlRequest, completionHandler: completionHandler)
    }

    func download(url: String, miniAppId: String, miniAppVersion: String) {
        guard let downLoadURL = downloadApi.createURLFromString(urlString: url) else {
            return
        }
        idsForUrls[url] = (miniAppId, miniAppVersion)
        session.startDownloadTask(downloadUrl: downLoadURL)
    }

    func getPreviewMiniAppInfo(using token: String,
                               completionHandler: @escaping MAResponseDataHandler) {
        guard let urlRequest = self.previewMiniappApi.createURLRequest(previewToken: token) else {
            return completionHandler(.failure(.invalidURLError))
        }
        return requestDataFromServer(urlRequest: urlRequest, completionHandler: completionHandler)
    }

    /// Method added to return MASDKError and which could be easy to handle in the Host app side.
    func requestDataFromServer(urlRequest: URLRequest, retry500: Int = 0, completionHandler: @escaping MAResponseDataHandler) {
        return session.startDataTask(with: urlRequest) { (result) in
            switch result {
            case .success(let responseData):
                let statusCode = responseData.httpResponse.statusCode
                let logIcon = statusCode < 300 ? "🟢" : "🟠"
                MiniAppLogger.d("[\(statusCode)] urlRequest \(urlRequest.url?.absoluteString ?? "-") : \n\(String(data: responseData.data, encoding: .utf8) ?? "Empty response")", logIcon)
                responseData.httpResponse.allHeaderFields.forEach { key, value in  MiniAppLogger.d("[\(key)]\t \(value)", "\t🎩")}

                if !(200...299).contains(statusCode) {
                    let failure = self.handleHttpErrorResponse(responseData: responseData.data, httpResponse: responseData.httpResponse)
                    if statusCode >= 500, retry500 < 5 {
                        let backOff = 2.0
                        let retry = retry500 + 1
                        let waitTime = 0.5*pow(backOff, Double(retry500))
                        let failureMessage = "\(failure.localizedDescription) : Attempt [\(retry)]."
                        MiniAppLogger.d("\(failureMessage) \nRetry in \(waitTime)s", "🟠")
                        return DispatchQueue.main.asyncAfter(deadline: .now() + waitTime) {
                            self.requestDataFromServer(urlRequest: urlRequest, retry500: retry, completionHandler: completionHandler)
                        }
                    }
                    MiniAppLogger.d("\(failure.localizedDescription)", "🔴")
                    return completionHandler(.failure(failure))
                }
                return completionHandler(.success(ResponseData(responseData.data,
                                                               responseData.httpResponse)))
            case .failure(let error):
                MiniAppLogger.d("urlRequest \(urlRequest.url?.absoluteString ?? "-") : Failure", "🔴")
                return completionHandler(.failure(.fromError(error: error)))
            }
        }
    }

    func handleHttpErrorResponse(responseData: Data, httpResponse: HTTPURLResponse) -> MASDKError {
        let code = httpResponse.statusCode
        var message: String

        switch code {
        case 401, 403:
            guard let errorModel = ResponseDecoder.decode(decodeType: UnauthorizedData.self, data: responseData) else {
                let error = NSError.unknownServerError(httpResponse: httpResponse)
                return MASDKError.unknownError(domain: error.domain, code: error.code, description: error.description)
            }
            message = "\(errorModel.error): \(errorModel.errorDescription)"
        default:
            guard let errorModel = ResponseDecoder.decode(decodeType: ErrorData.self, data: responseData) else {
                let error = NSError.unknownServerError(httpResponse: httpResponse)
                return MASDKError.unknownError(domain: error.domain, code: error.code, description: error.description)
            }
            message = errorModel.message
        }

        return MASDKError.serverError(code: code, message: message)
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let originalURLString = downloadTask.currentRequest?.url?.absoluteString else {
            delegate?.downloadFileTaskCompleted(url: "", error: .downloadingFailed)
            return
        }
        fileDownloadCompleted(originalURLString: originalURLString, at: location)
    }

    private func fileDownloadCompleted(originalURLString: String, at location: URL) {
        isSignatureVerified = false
        isDownloadStatusUpdated = false
        let ids = idsForUrls[originalURLString]
        let tempPathDirName = (ids?.0 ?? "") + "/" + (ids?.1 ?? "")
        guard let tempLocation = self.delegate?.moveFileToTempLocation(from: location, to: tempPathDirName) else {
            delegate?.downloadFileTaskCompleted(url: "", error: .downloadingFailed)
            return
        }
        checkFileSignature(originalURLString: originalURLString, location: tempLocation)
    }

    private func checkFileSignature(originalURLString: String, location: URL) {
        let ids = idsForUrls[originalURLString]
        #if RMA_SDK_SIGNATURE
            let requireMiniAppSignatureVerification = environment.requireMiniAppSignatureVerification
            if let versionId = ids?.1, let data = try? Data(contentsOf: location) {
                verifySignature(version: versionId, signature: signatures[versionId]?.1 ?? "", keyId: signatures[versionId]?.0 ?? "", data: data) { [weak self] isVerified in
                    if !isVerified { MiniAppAnalytics.sendAnalytics(event: .signatureFailure, miniAppId: ids?.0, miniAppVersion: versionId) }
                    let shouldPassTest =  isVerified || !requireMiniAppSignatureVerification // if verification is not required, the test should pass even is the signature is not verified
                    self?.delegate?.fileDownloaded(at: location, downloadedURL: originalURLString, signatureChecked: shouldPassTest)
                    self?.isSignatureVerified = true
                    if self?.isDownloadStatusUpdated == false {
                        self?.delegate?.downloadFileTaskCompleted(url: originalURLString, error: nil)
                    }
                    self?.cleanUpTmpFolder(tmpDirectory: ids?.0 ?? "")
                }
            } else {
                MiniAppAnalytics.sendAnalytics(event: .signatureFailure, miniAppId: ids?.0, miniAppVersion: ids?.1)
                delegate?.fileDownloaded(at: location, downloadedURL: originalURLString, signatureChecked: !requireMiniAppSignatureVerification)
                cleanUpTmpFolder(tmpDirectory: ids?.0 ?? "")
            }
        #else
            MiniAppAnalytics.sendAnalytics(event: .signatureFailure, miniAppId: ids?.0, miniAppVersion: ids?.1)
            delegate?.fileDownloaded(at: location, downloadedURL: originalURLString, signatureChecked: true)
            cleanUpTmpFolder(tmpDirectory: ids?.0 ?? "")
        #endif
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let url = task.currentRequest?.url?.absoluteString else {
            delegate?.downloadFileTaskCompleted(url: "", error: .downloadingFailed)
            return
        }
        guard let errorInfo = error else {
            downloadSessionCompleted(error: nil, urlString: url)
            return
        }
        downloadSessionCompleted(error: .fromError(error: errorInfo), urlString: url)
    }

    private func downloadSessionCompleted(error: MASDKError?, urlString: String) {
        #if RMA_SDK_SIGNATURE
            if isSignatureVerified {
                isDownloadStatusUpdated = true
                delegate?.downloadFileTaskCompleted(url: urlString, error: error)
            } else {
                isDownloadStatusUpdated = false
            }
        #else
            delegate?.downloadFileTaskCompleted(url: urlString, error: error)
        #endif
    }

    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        updateSSLPinConfig()
        if sslPinningConfig == nil || environment.sslKeyHash == nil {
            completionHandler(.performDefaultHandling, nil)
        } else if !TrustKit.sharedInstance().pinningValidator.handle(challenge, completionHandler: completionHandler) {
            MiniAppLogger.w("TrustKit did not handle this challenge: perhaps it was not for server trust or the domain was not pinned. Fall back to the default behavior")
            completionHandler(.performDefaultHandling, nil)
        }
    }

    /// Deleting the temporary directory that is created after downloading the mini-app file.
    func cleanUpTmpFolder(tmpDirectory: String) {
        if tmpDirectory.isEmpty { return }
        do {
            try FileManager.default.removeItem(at: FileManager.default.temporaryDirectory.appendingPathComponent(tmpDirectory))
        } catch let err {
            MiniAppLogger.e("error deleting Tmp folder", err)
        }
    }
}
