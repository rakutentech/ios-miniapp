import WebKit

internal class MiniAppWebView: WKWebView {

    convenience init(filePath: URL) {
        let config = WKWebViewConfiguration()
        self.init(frame: .zero, configuration: config)
        contentMode = .scaleToFill
        loadFileURL(filePath, allowingReadAccessTo: filePath.deletingLastPathComponent())
    }
}
