class MiniAppDownloader {
    enum MiniAppArchiveError: Error {
        case noRoot
    }
    private var miniAppClient: MiniAppClient
    private var miniAppStorage: MiniAppStorage
    private var manifestDownloader: ManifestDownloader
    private var urlToDirectoryMap = [String: DownloadOperation]()
    private var miniAppStatus: MiniAppStatus
    private var cacheVerifier: MiniAppCacheVerifier

    private var time: Date

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
        self.time = Date()
        self.cacheVerifier = MiniAppCacheVerifier()
    }

    fileprivate func cleanApp(_ appId: String, for version: String) {
        miniAppStorage.cleanVersions(for: appId, differentFrom: version, status: miniAppStatus)
    }

    func verifyAndDownload(appId: String, versionId: String, completionHandler: @escaping (Result<URL, Error>) -> Void) {
        if isMiniAppAlreadyDownloaded(appId: appId, versionId: versionId) {
            if !miniAppClient.environment.isPreviewMode, cacheVerifier.verify(appId: appId, version: versionId) {
                cleanApp(appId, for: versionId)
                let miniAppStoragePath = FileManager.getMiniAppVersionDirectory(with: appId, and: versionId)
                MiniAppLogger.d("\(miniAppStoragePath.absoluteString)", "📂")
                completionHandler(.success(miniAppStoragePath))
            } else {
                MiniAppLogger.w("Cached Mini App did not pass the hash verification. The Mini App will be re-downloaded.")

                cleanApp(appId, for: "")
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
                self.startDownloadingFiles(urls: responseData.manifest, to: miniAppStoragePath, miniAppId: appId, miniAppVersion: versionId) { downloadResult in
                    switch downloadResult {
                    case .success:
                        DispatchQueue.main.async {
                            self.cleanApp(appId, for: versionId)
                            self.cacheVerifier.storeHash(for: appId, version: versionId)
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

    private func startDownloadingFiles(urls: [String], to miniAppPath: URL, miniAppId: String, miniAppVersion: String, completionHandler: @escaping (Result<URL, Error>) -> Void) {
        self.miniAppClient.delegate = self
        time = Date()
        MiniAppLogger.d("MiniApp dl start")
        for url in urls {
            guard let urlString = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
                return
            }
            guard let fileDirectory = UrlParser.getFileStoragePath(from: url, with: self.miniAppClient.environment) else {
                completionHandler(.failure(NSError.downloadingFailed()))
                return
            }
            let filePath = miniAppPath.appendingPathComponent(fileDirectory)
            if !FileManager.default.fileExists(atPath: filePath.path) {
                urlToDirectoryMap[urlString] = DownloadOperation(fileStoragePath: filePath, miniAppDirectoryPath: miniAppPath, completionHandler: completionHandler)
                queue.addOperation {
                    self.miniAppClient.download(url: urlString, miniAppId: miniAppId, miniAppVersion: miniAppVersion)
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
        #if RMA_SDK_SIGNATURE
            fileDownloaded(at: sourcePath, downloadedURL: destinationPath, signatureChecked: !miniAppClient.environment.requireMiniAppSignatureVerification)
        #else
            fileDownloaded(at: sourcePath, downloadedURL: destinationPath, signatureChecked: true)
        #endif
    }

    /// Delegate called only when file is downloaded successfully
    /// Downloaded file should be taken care by moving them to any directory before returning the function.
    ///
    /// - Parameters:
    ///     - tempFilePath: Temporary file path where the downloaded file is stored
    ///     - downloadedURL: URL of the file which was downloaded
    ///     - signatureChecked: Boolean to determine if the file signature check went as expected
    func fileDownloaded(at sourcePath: URL, downloadedURL destinationPath: String, signatureChecked: Bool) {
        if signatureChecked {
            guard let filePath = urlToDirectoryMap[destinationPath]?.fileStoragePath
            else {
                return
            }
            MiniAppLogger.d("MiniApp dl time: \(Date().timeIntervalSince(time))")
            time = Date()
            guard let error = miniAppStorage.save(sourcePath: sourcePath, destinationPath: filePath)
            else {
                MiniAppLogger.d("MiniApp save time: \(Date().timeIntervalSince(time))")
                time = Date()
                unzipFile(fromURL: destinationPath, to: filePath)
                return
            }
            urlToDirectoryMap[destinationPath]?.completionHandler(.failure(error))
            return
        }
        urlToDirectoryMap[destinationPath]?.completionHandler(.failure(NSError.invalidSignature()))
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

    internal func unzipFile(fromURL destinationPath: String, to filePath: URL) {
        if let directory = urlToDirectoryMap[destinationPath]?.miniAppDirectoryPath, filePath.fileExtension() == "zip" {
            do {
                try FileManager.default.unzipItem(at: filePath, to: directory, skipCRC32: true)
                MiniAppLogger.d("MiniApp unzip time: \(Date().timeIntervalSince(time))")
                let path = "\(directory.path)/\(Constants.rootFileName)"
                MiniAppLogger.d("MiniApp unzip file: \(path)")
                if !FileManager.default.fileExists(atPath: path) {
                    throw MiniAppArchiveError.noRoot
                }
            } catch let err {
                MiniAppLogger.e("error unzipping archive", err)
                urlToDirectoryMap[destinationPath]?.completionHandler(.failure(err))
            }

            do {
                try FileManager.default.removeItem(at: filePath)
            } catch let err {
                MiniAppLogger.e("error deleting archive", err)
            }
        }
    }
}
