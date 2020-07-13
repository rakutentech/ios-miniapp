import WebKit

internal class RealMiniAppView: UIView, MiniAppDisplayProtocol, MiniAppCallbackProtocol, URLSessionDelegate, WKNavigationDelegate {
    internal var webView: WKWebView
    internal weak var hostAppMessageDelegate: MiniAppMessageProtocol?
    var localServer: LocalServer?

    init(miniAppId: String, versionId: String, hostAppMessageDelegate: MiniAppMessageProtocol) {
        webView = MiniAppWebView()
        self.hostAppMessageDelegate = hostAppMessageDelegate
        localServer = LocalServer()
        localServer?.startServer(appId: miniAppId, versionId: versionId, isSecure: true)
        super.init(frame: .zero)
        webView.configuration.userContentController.addMiniAppScriptMessageHandler(delegate: self, hostAppMessageDelegate: hostAppMessageDelegate)
        webView.configuration.userContentController.addBridgingJavaScript()
        webView.navigationDelegate = self
        addSubview(webView)
        loadWebpage(versionId: versionId)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        webView.frame = bounds
    }

    public func getMiniAppView() -> UIView {
        return self
    }

    override func removeFromSuperview() {
        localServer?.stopServer()
        localServer = nil
        super.removeFromSuperview()
    }

    func loadWebpage(versionId: String) {
        guard let serverUrl = localServer?.serverURL().absoluteString else {
            return
        }

        let url = URL(string: "\(serverUrl)/\(versionId)/index.html")!
        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: nil)
        let task = session.dataTask(with: url) {(data, _, _) in
            guard let data = data else { return }
            DispatchQueue.main.async {
                self.webView.load(data, mimeType: "text/html", characterEncodingName: "uft8", baseURL: url)
            }
        }
        task.resume()
    }

    func didReceiveScriptMessageResponse(messageId: String, response: String) {
        self.webView.evaluateJavaScript(Constants.javascriptSuccessCallback + "('\(messageId)'," + "'\(response)')")
    }

    func didReceiveScriptMessageError(messageId: String, errorMessage: String) {
        self.webView.evaluateJavaScript(Constants.javascriptErrorCallback + "('\(messageId)'," + "'\(errorMessage)')")
    }

    deinit {
        webView.configuration.userContentController.removeMessageHandler()
    }

    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        var disposition: URLSession.AuthChallengeDisposition = .performDefaultHandling
        var credential: URLCredential?

        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            disposition = URLSession.AuthChallengeDisposition.useCredential
            credential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
        } else {
            if challenge.previousFailureCount > 0 {
                disposition = .cancelAuthenticationChallenge
            } else {
                credential = session.configuration.urlCredentialStorage?.defaultCredential(for: challenge.protectionSpace)
                if credential != nil {
                    disposition = .useCredential
                }
            }
        }
        completionHandler(disposition, credential)
    }

    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        guard let serverTrust = challenge.protectionSpace.serverTrust else {
            return completionHandler(.useCredential, nil)
        }
        let exceptions = SecTrustCopyExceptions(serverTrust)
        SecTrustSetExceptions(serverTrust, exceptions)
        completionHandler(.useCredential, URLCredential(trust: serverTrust))
    }
}
