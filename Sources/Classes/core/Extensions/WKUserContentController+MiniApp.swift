import WebKit

extension WKUserContentController {

    /// Method to add Mini App custom WKScriptMessageHandler.
    /// - Parameters:
    ///   - delegate: Callback protocol to handle the message from the WebView
    ///   - adsDisplayer: a MiniAppAdDisplayer that will handle ads requests
    ///   - hostAppMessageDelegate: Message interface protocol of the host application
    ///   - miniAppId: Mini App id String value
    ///   - miniAppTitle: Mini App title provided to Javascript handler
    func addMiniAppScriptMessageHandler(delegate: MiniAppCallbackDelegate, hostAppMessageDelegate: MiniAppMessageDelegate, adsDisplayer: MiniAppAdDisplayer?, miniAppId: String, miniAppTitle: String) {
        [Constants.JavaScript.interfaceName,
         Constants.JavaScript.logHandler].forEach { (name) in
            add(MiniAppScriptMessageHandler(
                    delegate: delegate,
                    hostAppMessageDelegate: hostAppMessageDelegate,
                    adsDisplayer: adsDisplayer,
                    miniAppId: miniAppId,
                    miniAppTitle: miniAppTitle
            ), name: name)
        }
    }

    /// Method to remove the custom WKScriptMessageHandler. Removing the message handler will help to avoid memory leaks
    func removeMessageHandler() {
        removeScriptMessageHandler(forName: Constants.JavaScript.interfaceName)
        removeScriptMessageHandler(forName: Constants.JavaScript.logHandler)
    }

    /// Method to add the Bridging Javascript to the WebView User Controller
    /// This JavaScript is responsible for communication between SDK and Mini App
    /// Any request from Mini App is communicated via the contract available in the Bridging script
    func addBridgingJavaScript(podBundle: Bundle = Bundle.miniAppSDKBundle()) {
        injectScript(from: "bridge", in: podBundle)

        #if DEBUG
        // copy logs from javascript console
        injectScript(from: "log", in: podBundle)
        #endif
    }

    func injectScript(from file: String, in bundle: Bundle) {
        guard let javascriptPath = bundle.path(forResource: file, ofType: "js"),
            let javascriptSource = try? String(contentsOfFile: javascriptPath) else { return }

        let userScript = WKUserScript(source: javascriptSource, injectionTime: .atDocumentStart, forMainFrameOnly: true)
         addUserScript(userScript)
    }
}
