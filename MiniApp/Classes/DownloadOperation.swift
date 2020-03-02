class DownloadOperation {
    typealias DownloadCompletionHandler = (Result<URL, Error>) -> Void

    private var completionHandler: DownloadCompletionHandler?
    private var urlToDirectoryMap = [String: URL]()
    private var miniAppClient: MiniAppClient
    private var miniAppStorage: MiniAppStorage
    private var miniAppPath: URL

    private var queue: OperationQueue = {
        let operationQueue = OperationQueue()
        operationQueue.name = "MiniAppDownloader"
        operationQueue.maxConcurrentOperationCount = 4
        return operationQueue
    }()

    init(miniAppStorage: MiniAppStorage, miniAppClient: MiniAppClient, miniAppPath: URL, completionHandler: @escaping DownloadCompletionHandler) {
        self.miniAppClient = miniAppClient
        self.miniAppStorage = miniAppStorage
        self.miniAppPath = miniAppPath
        self.completionHandler = completionHandler
    }

    func downloadFiles(urls: [String]) {
        self.miniAppClient.delegate = self
        for url in urls {
            guard let fileDirectory = UrlParser.parseForFileDirectory(with: url) else {
                self.completionHandler?(.failure(NSError.downloadingFailed()))
                return
            }
            if !FileManager.default.fileExists(atPath: self.miniAppPath.appendingPathComponent(fileDirectory).path) {
                urlToDirectoryMap[url] = self.miniAppPath.appendingPathComponent(fileDirectory)
                queue.addOperation {
                    self.miniAppClient.download(url: url)
                }
            }
        }
        if urlToDirectoryMap.isEmpty {
            self.completionHandler?(.success(self.miniAppPath))
        }
    }

    func cancelAllOperations() {
        queue.cancelAllOperations()
    }
}

extension DownloadOperation: MiniAppDownloaderProtocol {

    func fileDownloaded(sourcePath: URL, destinationPath: String) {
        guard let filePath = urlToDirectoryMap[destinationPath] else {
            return
        }
        guard let error = self.miniAppStorage.save(sourcePath: sourcePath, destinationPath: filePath) else {
            return
        }
        self.completionHandler?(.failure(error))
    }

    func downloadCompleted(url: String, error: Error?) {
        guard let error = error else {
            urlToDirectoryMap.removeValue(forKey: url)
            if urlToDirectoryMap.isEmpty {
                self.completionHandler?(.success(self.miniAppPath))
            }
            return
        }
        self.completionHandler?(.failure(error))
    }
}
