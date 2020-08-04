class MiniAppDownloader {

    private var miniAppClient: MiniAppClient
    private var miniAppStorage: MiniAppStorage
    private var manifestDownloader: ManifestDownloader
    private var urlToDirectoryMap = [String: DownloadOperation]()
    private var miniAppStatus: MiniAppStatus
    private var cacheVerifier: MiniAppCacheVerifier

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
        self.cacheVerifier = MiniAppCacheVerifier()
    }

    func verifyAndDownload(appId: String, versionId: String, completionHandler: @escaping (Result<URL, Error>) -> Void) {
        if isMiniAppAlreadyDownloaded(appId: appId, versionId: versionId) {
            if cacheVerifier.verify(appId: appId) {
                let miniAppStoragePath = FileManager.getMiniAppVersionDirectory(with: appId, and: versionId)
                completionHandler(.success(miniAppStoragePath))
            } else {
                MiniAppLogger.w("Cached Mini App did not pass the hash verification. The Mini App will be re-downloaded.")

                self.miniAppStorage.cleanVersions(for: appId, differentFrom: "", status: self.miniAppStatus)
                download(appId: appId, versionId: versionId, completionHandler: completionHandler)
            }
        } else {
            download(appId: appId, versionId: versionId, completionHandler: completionHandler)
        }
    }

    private func download(appId: String, versionId: String, completionHandler: @escaping (Result<URL, Error>) -> Void) {
        let miniAppStoragePath = FileManager.getMiniAppVersionDirectory(with: appId, and: versionId)
        self.manifestDownloader.fetchManifest(apiClient: self.miniAppClient, appId: appId, versionId: versionId) { (result) in
            switch result {
            case .success(let responseData):
                self.startDownloadingFiles(urls: responseData.manifest, to: miniAppStoragePath) { downloadResult in
                    switch downloadResult {
                    case .success:
                        DispatchQueue.main.async {
                            self.miniAppStorage.cleanVersions(for: appId, differentFrom: versionId, status: self.miniAppStatus)

                            self.cacheVerifier.storeHash(for: appId)
                        }

                        fallthrough
                    default:
                        completionHandler(downloadResult)
                    }
                }
            case .failure(let error):
                completionHandler(.failure(error))
            }
        }
    }

    func isMiniAppAlreadyDownloaded(appId: String, versionId: String) -> Bool {
        if miniAppStatus.isDownloaded(appId: appId, versionId: versionId) {
            let versionDirectory = FileManager.getMiniAppVersionDirectory(with: appId, and: versionId)
            var isDirectory: ObjCBool = true
            if FileManager.default.fileExists(atPath: versionDirectory.path, isDirectory: &isDirectory) {
                return true
            }
        }
        return false
    }

    /// Check if there is any old version of mini app cached for a given app ID
    /// - Parameter appId: App ID for which the version directory path to be fetched
    /// - Parameter versionId: Version ID of the app info
    /// - Returns: URL of the available cached version for a given mini app ID
    func getCachedMiniAppVersion(appId: String, versionId: String) -> String? {
        if !isMiniAppAlreadyDownloaded(appId: appId, versionId: versionId) {
            let cachedVersion = self.miniAppStatus.getCachedVersion(key: appId)
            if !cachedVersion.isEmpty {
                var isDirectory: ObjCBool = true
                let miniAppPath = FileManager.getMiniAppVersionDirectory(with: appId, and: cachedVersion)
                if FileManager.default.fileExists(atPath: miniAppPath.path, isDirectory: &isDirectory) {
                    return cachedVersion
                }
            }
            return nil
        } else {
            let versionDirectory = FileManager.getMiniAppVersionDirectory(with: appId, and: versionId)
            var isDirectory: ObjCBool = true
            if FileManager.default.fileExists(atPath: versionDirectory.path, isDirectory: &isDirectory) {
                return versionId
            }
        }
        return nil
    }

    private func startDownloadingFiles(urls: [String], to miniAppPath: URL, completionHandler: @escaping (Result<URL, Error>) -> Void) {
        self.miniAppClient.delegate = self
        for url in urls {
            guard let urlString = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
                return
            }
            guard let fileDirectory = UrlParser.getFileStoragePath(from: url) else {
                completionHandler(.failure(NSError.downloadingFailed()))
                return
            }
            let filePath = miniAppPath.appendingPathComponent(fileDirectory)
            if !FileManager.default.fileExists(atPath: filePath.path) {
                urlToDirectoryMap[urlString] = DownloadOperation(fileStoragePath: filePath, miniAppDirectoryPath: miniAppPath, completionHandler: completionHandler)
                queue.addOperation {
                    self.miniAppClient.download(url: urlString)
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
        urlToDirectoryMap[destinationPath]?.completionHandler(.failure(error))
    }

    /// Delegate called whenever download task is completed/failed.
    /// This method will be called everytime any download file task is completed/failed
    ///
    /// - Parameters:
    ///   - url: URL of the file which was downloaded
    ///   - error: Error information if the downloading is failed with error
    func downloadFileTaskCompleted(url: String, error: Error?) {
        let completionHandler = urlToDirectoryMap[url]?.completionHandler
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
