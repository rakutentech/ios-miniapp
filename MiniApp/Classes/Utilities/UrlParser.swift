/**
 * Utility class to help process URL parsing operations.
 */
struct UrlParser {

    static let separatorKey: String = "map-published/"
    static let dropLimit = 2

    /**
     * Parses for the file directory from an URL provided in a manifest.
     * @param { url: String } - URL to parse through.
     * @return { String } - The file directory after removing the base URL.
     */
    static func getFileStoragePath(from url: String) -> String? {
        if url.contains(separatorKey) {
            var pathComponents: [String] = url.components(separatedBy: separatorKey)
            guard let path: String = pathComponents.last, !path.isEmpty else {
                MiniAppLogger.e("MiniAppSDK: Failed parsing URL.")
                return nil
            }
            pathComponents = path.components(separatedBy: "/")
            // Number of elements to drop from the after the separator
            // For eg., /min-abc/ver-abc/img/test.png
            // Following code will remove /min-abc/ver-abc/
            let fullPath = pathComponents.dropFirst(dropLimit)
            return NSString.path(withComponents: Array(fullPath))
        }
        return nil
    }
}
