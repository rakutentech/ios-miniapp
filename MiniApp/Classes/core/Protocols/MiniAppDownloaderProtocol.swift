/**
 * Protocol for the Downloader class that handles downloading the files for Mini App.
 */
protocol MiniAppDownloaderProtocol: class {

    func fileDownloaded(at tempFilePath: URL, downloadedURL: String)

    func downloadFileTaskCompleted(url: String, error: Error?)
}
