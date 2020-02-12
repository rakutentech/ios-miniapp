/**
 * Protocol for the Downloader class that handles downloading the files for Mini App.
 */
protocol MiniAppDownloaderProtocol: class {

    func fileDownloaded(sourcePath: URL, destinationPath: String)

    func downloadCompleted(url: String, error: Error?)
}
