import Foundation

/**
 * Protocol for the Downloader class that handles downloading the files for Mini App.
 */
protocol MiniAppDownloaderProtocol: AnyObject {

    func fileDownloaded(at tempFilePath: URL, downloadedURL: String, signatureChecked: Bool)
    func downloadFileTaskCompleted(url: String, error: MASDKError?)
    func moveFileToTempLocation(from sourcePath: URL, to tempLocation: String?) -> URL?
}
