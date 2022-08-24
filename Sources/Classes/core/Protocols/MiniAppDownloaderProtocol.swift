import Foundation

/**
 * Protocol for the Downloader class that handles downloading the files for Mini App.
 */
protocol MiniAppDownloaderProtocol: AnyObject {

    func fileDownloaded(at tempFilePath: URL, downloadedURL: String, signatureChecked: Bool)
    func downloadFileTaskCompleted(url: String, error: MASDKError?)
    func moveFileToTempLocation(from sourcePath: URL, to tempLocation: String?) -> URL?
}

protocol MiniAppDownloaderInterface: MiniAppDownloaderProtocol {
    func verifyAndDownload(appId: String, versionId: String, completionHandler: @escaping (Result<URL, MASDKError>) -> Void)
    func isMiniAppAlreadyDownloaded(appId: String, versionId: String) -> Bool
    func getCachedMiniAppVersion(appId: String, versionId: String) -> String?
    func isCacheSecure(appId: String, versionId: String) -> Bool
}
