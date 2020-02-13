import WebKit

internal class MiniAppWebView: WKWebView {

    convenience init?(filePath: URL) {
        if !filePath.isFileURL {
            return nil
        }
        let config = WKWebViewConfiguration()
        config.preferences.javaScriptEnabled = true
        self.init(frame: .zero, configuration: config)
        contentMode = .scaleToFill
        loadFileURL(filePath, allowingReadAccessTo: filePath.deletingLastPathComponent())
    }
}
