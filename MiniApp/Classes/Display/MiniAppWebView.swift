import WebKit

internal class MiniAppWebView: WKWebView {

    convenience init?(filePath: URL) {
        let fileURL = filePath.appendingPathComponent(Constants.FileNames.baseFile)
        if !filePath.isFileURL {
            return nil
        }
        let config = WKWebViewConfiguration()
        config.preferences.javaScriptEnabled = true
        self.init(frame: .zero, configuration: config)
        contentMode = .scaleToFill
        loadFileURL(fileURL, allowingReadAccessTo: filePath.deletingLastPathComponent())
    }
}
