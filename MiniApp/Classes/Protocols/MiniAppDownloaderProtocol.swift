/**
 * Protocol for the Downloader class that handles downloading the files for Mini App.
 */
protocol MiniAppDownloaderProtocol: class {

    func downloadedFileData(downloadTask: URLSessionDownloadTask, location: URL)

    func downloadCompleted(task: URLSessionTask, error: Error?)
}
