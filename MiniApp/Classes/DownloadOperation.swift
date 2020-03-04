class DownloadOperation {
    typealias DownloadCompletionHandler = (Result<URL, Error>) -> Void

    var fileStoragePath: URL
    var miniAppDirectoryPath: URL
    var completionHanlder: DownloadCompletionHandler

    init(fileStoragePath: URL, miniAppDirectoryPath: URL, completionHanlder: @escaping DownloadCompletionHandler) {
        self.fileStoragePath = fileStoragePath
        self.miniAppDirectoryPath = miniAppDirectoryPath
        self.completionHanlder = completionHanlder
    }
}
