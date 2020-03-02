class MiniAppDownloader {

    private var miniAppClient: MiniAppClient
    private var miniAppStorage: MiniAppStorage
    private var manifestDownloader: ManifestDownloader
    private var urlToDirectoryMap = [String: URL]()
    private var miniAppStatus: MiniAppStatus

    init(apiClient: MiniAppClient, manifestDownloader: ManifestDownloader, status: MiniAppStatus) {
        self.miniAppClient = apiClient
        self.miniAppStorage = MiniAppStorage()
        self.manifestDownloader = manifestDownloader
        self.miniAppStatus = status
    }

    func download(appId: String, versionId: String, completionHandler: @escaping (Result<URL, Error>) -> Void) {
        let miniAppStoragePath = FileManager.getMiniAppDirectory(with: appId, and: versionId)
        if miniAppStatus.isDownloaded(key: "\(appId)/\(versionId)") {
            completionHandler(.success(miniAppStoragePath))
            return
        }
        self.manifestDownloader.fetchManifest(apiClient: self.miniAppClient, appId: appId, versionId: versionId) { (result) in
            switch result {
            case .success(let responseData):
                let downloadOperation = DownloadOperation(miniAppStorage: self.miniAppStorage, miniAppClient: self.miniAppClient, miniAppPath: miniAppStoragePath, completionHandler: completionHandler)
                downloadOperation.downloadFiles(urls: responseData.manifest)
            case .failure(let error):
                return completionHandler(.failure(error))
            }
        }
    }
}
