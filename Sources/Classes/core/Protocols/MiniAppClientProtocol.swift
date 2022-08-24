import Foundation

internal protocol MiniAppClientProtocol {
    var listingApi: ListingApi {get}
    var manifestApi: ManifestApi {get}
    var downloadApi: DownloadApi {get}
    var metaDataApi: MetaDataAPI {get}
    var previewMiniappApi: PreviewMiniappAPI {get}
    var environment: Environment {get set}
    var sslPinningConfig: MiniAppSSLConfig? {get set}

    var delegate: MiniAppDownloaderProtocol? {get set}

    func updateSSLPinConfig()
    func updateEnvironment(with config: MiniAppSdkConfig?)

    func getMiniAppsList(
        completionHandler: @escaping MiniAppClient.MAResponseDataHandler
    )

    func getMiniApp(
        _ miniAppId: String,
        completionHandler: @escaping MiniAppClient.MAResponseDataHandler
    )

    func getAppManifest(
        appId: String,
        versionId: String,
        completionHandler: @escaping MiniAppClient.MAResponseDataHandler
    )

    func getMiniAppMetaData(
        appId: String,
        versionId: String,
        languageCode: String,
        completionHandler: @escaping MiniAppClient.MAResponseDataHandler
    )

    func download(
        url: String,
        miniAppId: String,
        miniAppVersion: String
    )

    func getPreviewMiniAppInfo(
        using token: String,
        completionHandler: @escaping MiniAppClient.MAResponseDataHandler
    )

    func requestDataFromServer(
        urlRequest: URLRequest,
        retry500: Int,
        completionHandler: @escaping MiniAppClient.MAResponseDataHandler
    )

    func handleHttpErrorResponse(
        responseData: Data,
        httpResponse: HTTPURLResponse
    ) -> MASDKError

    func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didFinishDownloadingTo location: URL
    )
}
