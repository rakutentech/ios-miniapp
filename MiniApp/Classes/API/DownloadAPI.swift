internal class DownloadApi {
    let environment: Environment

    init(environment: Environment) {
        self.environment = environment
    }

    func createURLFromString(urlString: String) -> URL? {
        guard let url = URL(string: urlString) else {
            return nil
        }
        return url
    }
}
