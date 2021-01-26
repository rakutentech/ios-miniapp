/**
 * Utility class to help process URL parsing operations.
 */
struct UrlParser {

    static let dropLimit = 2

    /**
     * Parses for the file directory from an URL provided in a manifest.
     * @param { url: String } - URL to parse through.
     * @return { String } - The file directory after removing the base URL.
     */
    static func getFileStoragePath(from url: String, with environmemt: Environment) -> String? {
        if let baseUrl = environmemt.baseUrl {
            let path: String = url.replacingOccurrences(of: baseUrl.absoluteString, with: "")
            if path.isEmpty {
                MiniAppLogger.e("MiniAppSDK: Failed parsing URL.")
                return nil
            }
            let pathComponents = path.components(separatedBy: "/")
            // Number of elements to drop from the after the separator
            // For eg., /min-abc/ver-abc/img/test.png
            // Following code will remove /min-abc/ver-abc/
            let fullPath = pathComponents.dropFirst(dropLimit)
            return NSString.path(withComponents: Array(fullPath))
        }
        return nil
    }
}
