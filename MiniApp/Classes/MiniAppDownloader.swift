class MiniAppDownloader {

    typealias DownloadCompletionHandler = (Result<Bool, Error>) -> Void

    private var miniAppClient: MiniAppClient
    private var miniAppStorage: MiniAppStorage
    private var manifestDownloader: ManifestDownloader
    private var completionHandler: DownloadCompletionHandler?
    private var urlToDirectoryMap = [String: URL]()

    private var queue: OperationQueue = {
        let operationQueue = OperationQueue()
        operationQueue.name = "MiniAppDownloader"
        operationQueue.maxConcurrentOperationCount = 4

        return operationQueue
    }()

    init(apiClient: MiniAppClient, manifestDownloader: ManifestDownloader) {
        self.miniAppClient = apiClient
        self.miniAppStorage = MiniAppStorage()
        self.manifestDownloader = manifestDownloader
    }

    func download(appId: String, versionId: String, completionHandler: @escaping (Result<Bool, Error>) -> Void) {
        self.manifestDownloader.fetchManifest(apiClient: self.miniAppClient, appId: appId, versionId: versionId) { (result) in
            switch result {
            case .success(let responseData):
                self.completionHandler = completionHandler
                self.downloadManifestFiles(with: appId, versionId: versionId, files: responseData.manifest)
            case .failure(let error):
                return completionHandler(.failure(error))
            }
        }
    }

    private func downloadManifestFiles(with appId: String, versionId: String, files: [String]) {
        guard let miniAppStoragePath = FileManager.getMiniAppDirectory(with: appId, and: versionId) else {
            return
        }
        downloadMiniApp(files, to: miniAppStoragePath)
    }

    private func downloadMiniApp(_ urls: [String], to miniAppPath: URL) {
        self.miniAppClient.delegate = self
        for url in urls {
            guard let fileDirectory = UrlParser.parseForFileDirectory(with: url) else {
                self.completionHandler?(.failure(NSError.downloadingFailed()))
                return
            }
            if !FileManager.default.fileExists(atPath: miniAppPath.appendingPathComponent(fileDirectory).path) {
                urlToDirectoryMap[url] = miniAppPath.appendingPathComponent(fileDirectory)
                queue.addOperation {
                    self.miniAppClient.download(url: url)
                }
            }
        }
        if urlToDirectoryMap.isEmpty {
            self.completionHandler?(.success(true))
        }
    }
}

extension MiniAppDownloader: MiniAppDownloaderProtocol {

    func fileDownloaded(sourcePath: URL, destinationPath: String) {
        guard let filePath = urlToDirectoryMap[destinationPath] else {
            return
        }
        guard let error = miniAppStorage.save(sourcePath: sourcePath, destinationPath: filePath) else {
            return
        }
        self.completionHandler?(.failure(error))
    }

    func downloadCompleted(url: String, error: Error?) {
        guard let error = error else {
            urlToDirectoryMap.removeValue(forKey: url)
            if urlToDirectoryMap.isEmpty {
                self.completionHandler?(.success(true))
            }
            return
        }
        self.completionHandler?(.failure(error))
    }
}
