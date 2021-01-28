class DownloadOperation {
    typealias DownloadCompletionHandler = (Result<URL, Error>) -> Void

    var fileStoragePath: URL
    var miniAppDirectoryPath: URL
    var completionHandler: DownloadCompletionHandler

    init(fileStoragePath: URL, miniAppDirectoryPath: URL, completionHandler: @escaping DownloadCompletionHandler) {
        self.fileStoragePath = fileStoragePath
        self.miniAppDirectoryPath = miniAppDirectoryPath
        self.completionHandler = completionHandler
    }
}
