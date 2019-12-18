/**
 * Utility class to help process URL parsing operations.
 */
struct UrlParser {

    /**
     * Parses for the file directory from an URL provided in a manifest.
     * @param { url: String } - URL to parse through.
     * @return { String } - The file directory after removing the base URL.
     */
    static func parseForFileDirectory(with url: String) -> String? {
        guard let versionId =
            url.components(separatedBy: "version/").last?.components(separatedBy: "/").first,
            let directory = url.components(separatedBy: "\(versionId)/").last
        else {
            #if DEBUG
                print("MiniAppSDK: Failed parsing URL.")
            #endif
            return nil
        }

        return directory
    }
}
