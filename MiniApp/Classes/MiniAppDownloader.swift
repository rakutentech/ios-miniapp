/**
 * Protocol for the Downloader class that handles downloading the files for Mini App.
 */
protocol MiniAppDownloaderProtocol {

    /// Handles downloading each file to a specific location.
    /// - Parameters:
    ///   - urls: [String] - List of URLs in the manifest.
    ///   - pathDirectory: URL - The system path directory to cache.
    func download(_ urls: [String], to pathDirectory: URL)
}

class MiniAppDownloader: NSObject, MiniAppDownloaderProtocol {

    private var urlToDirectoryMap = [String: URL]()

    private var queue: OperationQueue = {
        let operationQueue = OperationQueue()
        operationQueue.name = "MiniAppDownloader"
        operationQueue.maxConcurrentOperationCount = 4

        return operationQueue
    }()

    lazy var session: URLSession = {
        let configuration = URLSessionConfiguration.default
        return URLSession(configuration: configuration, delegate: self, delegateQueue: queue)
    }()

    func download(_ urls: [String], to pathDirectory: URL) {
        for url in urls {
            guard let fileDirectory = UrlParser.parseForFileDirectory(with: url),
                let downloadUrl = URL(string: url)
            else {
                #if DEBUG
                    print("MiniAppSDK: Invalid URL from manifest.")
                #endif
                return
            }

            urlToDirectoryMap[url] = pathDirectory.appendingPathComponent(fileDirectory)

            queue.addOperation {
                let task = self.session.downloadTask(with: downloadUrl)
                task.resume()
            }
        }
    }
}

/**
 * URLSessionDownloadDelegate methods for MiniAppDownloader.
 */
extension MiniAppDownloader: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let sourceURL = downloadTask.originalRequest?.url else {
            return
        }

        guard let destinationPath = urlToDirectoryMap[sourceURL.absoluteString] else {
            #if DEBUG
                print("MiniAppSDK: Failed to save files.")
            #endif
            return
        }

        try? FileManager.default.createDirectory(atPath: destinationPath.relativePath, withIntermediateDirectories: true)
        try? FileManager.default.removeItem(at: destinationPath)
        try? FileManager.default.copyItem(at: location, to: destinationPath)

        urlToDirectoryMap.removeValue(forKey: sourceURL.absoluteString)
    }
}
