/**
 * Protocol for the Downloader class that handles downloading the files for Mini App.
 */
protocol MiniAppDownloaderProtocol: AnyObject {

    @available(*, deprecated, renamed:"fileDownloaded(tempFilePath:downloadedURL:signatureChecked:)")
    func fileDownloaded(at tempFilePath: URL, downloadedURL: String)
    func fileDownloaded(at tempFilePath: URL, downloadedURL: String, signatureChecked: Bool)
    func downloadFileTaskCompleted(url: String, error: Error?)
}
