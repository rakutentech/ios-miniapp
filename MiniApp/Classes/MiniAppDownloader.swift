class MiniAppDownloader {

    private var miniAppClient: MiniAppClient
    private var miniAppStorage: MiniAppStorage
    private var manifestDownloader: ManifestDownloader
    private var urlToDirectoryMap = [String: DownloadOperation]()
    private var miniAppStatus: MiniAppStatus

    private var queue: OperationQueue = {
        let operationQueue = OperationQueue()
        operationQueue.name = "MiniAppDownloader"
        operationQueue.maxConcurrentOperationCount = 4

        return operationQueue
    }()

    init(apiClient: MiniAppClient, manifestDownloader: ManifestDownloader, status: MiniAppStatus) {
        self.miniAppClient = apiClient
        self.miniAppStorage = MiniAppStorage()
        self.manifestDownloader = manifestDownloader
        self.miniAppStatus = status
    }

    func download(appId: String, versionId: String, completionHandler: @escaping (Result<URL, Error>) -> Void) {
        let miniAppStoragePath = FileManager.getMiniAppVersionDirectory(with: appId, and: versionId)
        if miniAppStatus.isDownloaded(appId: appId, versionId: versionId) {
            completionHandler(.success(miniAppStoragePath))
            return
        }
        self.manifestDownloader.fetchManifest(apiClient: self.miniAppClient, appId: appId, versionId: versionId) { (result) in
            switch result {
            case .success(let responseData):
                self.downloadMiniApp(urls: responseData.manifest, to: miniAppStoragePath) { downloadResult in
                    switch downloadResult {
                    case .success:
                        self.miniAppStorage.cleanVersions(for: appId, differentFrom: versionId, status: self.miniAppStatus)

                        fallthrough
                    default:
                        completionHandler(downloadResult)
                    }
                }
            case .failure(let error):
                return completionHandler(.failure(error))
            }
        }
    }

    private func downloadMiniApp(urls: [String], to miniAppPath: URL, completionHandler: @escaping (Result<URL, Error>) -> Void) {
        self.miniAppClient.delegate = self
        for url in urls {
            guard let fileDirectory = UrlParser.parseForFileDirectory(with: url) else {
                completionHandler(.failure(NSError.downloadingFailed()))
                return
            }
            let filePath = miniAppPath.appendingPathComponent(fileDirectory)
            if !FileManager.default.fileExists(atPath: filePath.path) {
                urlToDirectoryMap[url] = DownloadOperation(fileStoragePath: filePath, miniAppDirectoryPath: miniAppPath, completionHanlder: completionHandler)
                queue.addOperation {
                    self.miniAppClient.download(url: url)
                }
            }
        }
        if urlToDirectoryMap.isEmpty {
            completionHandler(.success(miniAppPath))
        }
    }
}

extension MiniAppDownloader: MiniAppDownloaderProtocol {

    /// Delegate called only when file is downloaded successfully
    /// Downloaded file should be taken care by moving them to any directory before returning the function.
    ///
    /// - Parameters:
    ///     - tempFilePath: Temporary file path where the downloaded file is stored
    ///     - downloadedURL: URL of the file which was downloaded
    func fileDownloaded(at sourcePath: URL, downloadedURL destinationPath: String) {
        guard let filePath = urlToDirectoryMap[destinationPath]?.fileStoragePath else {
            return
        }
        guard let error = miniAppStorage.save(sourcePath: sourcePath, destinationPath: filePath) else {
            return
        }
        urlToDirectoryMap[destinationPath]?.completionHanlder(.failure(error))
    }

    /// Delegate called whenever download task is completed/failed.
    /// This method will be called everytime any download file task is completed/failed
    ///
    /// - Parameters:
    ///   - url: URL of the file which was downloaded
    ///   - error: Error information if the downloading is failed with error
    func downloadFileTaskCompleted(url: String, error: Error?) {
        let completionHandler = urlToDirectoryMap[url]?.completionHanlder
        guard let error = error else {
            guard let miniAppDirectoryPath = urlToDirectoryMap[url]?.miniAppDirectoryPath else {
                completionHandler?(.failure(NSError.downloadingFailed()))
                return
            }
            urlToDirectoryMap.removeValue(forKey: url)
            if urlToDirectoryMap.isEmpty {
                completionHandler?(.success(miniAppDirectoryPath))
            }
            return
        }
        completionHandler?(.failure(error))
    }
}
