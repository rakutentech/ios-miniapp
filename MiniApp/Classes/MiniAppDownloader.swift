class MiniAppDownloader {

    typealias DownloadCompletionHandler = (Result<URL?, Error>) -> Void

    var miniAppClient: MiniAppClient?
    var miniAppStorage: MiniAppStorage
    var manifestDownloader: ManifestDownloader
    var completionHandler: DownloadCompletionHandler?
    var miniAppDirectory: URL?

    private var urlToDirectoryMap = [String: URL]()

    private var queue: OperationQueue = {
        let operationQueue = OperationQueue()
        operationQueue.name = "MiniAppDownloader"
        operationQueue.maxConcurrentOperationCount = 4

        return operationQueue
    }()

    init() {
        self.miniAppStorage = MiniAppStorage()
        self.manifestDownloader = ManifestDownloader()
    }

    func download(with apiClient: MiniAppClient, appId: String, versionId: String, completionHandler: @escaping (Result<URL?, Error>) -> Void) {
        self.miniAppClient = apiClient
        self.manifestDownloader.fetchManifest(apiClient: apiClient, appId: appId, versionId: versionId) { (result) in
            switch result {
            case .success(let responseData):
                self.completionHandler = completionHandler
                self.downloadManifestFiles(with: appId, versionId: versionId, manifestResponse: responseData)
            case .failure(let error):
                return completionHandler(.failure(error))
            }
        }
    }

    private func downloadManifestFiles(with appId: String, versionId: String, manifestResponse: ManifestResponse) {
        guard let miniAppStoragePath = FileManager.getMiniAppDirectory(with: appId, and: versionId) else {
            return
        }
        miniAppDirectory = miniAppStoragePath
        downloadMiniApp(manifestResponse.files, to: miniAppStoragePath)
    }

    private func downloadMiniApp(_ urls: [String], to miniAppPath: URL) {
        self.miniAppClient?.delegate = self
        for url in urls {
            guard let fileDirectory = UrlParser.parseForFileDirectory(with: url) else {
                self.completionHandler?(.failure(NSError.downloadingFailed()))
                return
            }
            urlToDirectoryMap[url] = miniAppPath.appendingPathComponent(fileDirectory)
            queue.addOperation {
                self.miniAppClient?.download(url: url)
            }
        }
    }
}

extension MiniAppDownloader: MiniAppDownloaderProtocol {

    func downloadedFileData(downloadTask: URLSessionDownloadTask, location: URL) {
        guard let sourceURL = downloadTask.currentRequest?.url else {
            return
        }
        guard let destinationPath = urlToDirectoryMap[sourceURL.absoluteString] else {
            return
        }
        miniAppStorage.save(sourcePath: location, destinationPath: destinationPath)
    }

    func downloadCompleted(task: URLSessionTask, error: Error?) {
        guard let error = error else {
            guard let url = task.currentRequest?.url?.absoluteString else {
                return
            }
            urlToDirectoryMap.removeValue(forKey: url)
            if urlToDirectoryMap.isEmpty {
                self.completionHandler?(.success(self.miniAppDirectory))
            }
            return
        }
        self.completionHandler?(.failure(error))
    }
}
