import WebKit

extension WKUserContentController {

    /// Method to add Mini App custom WKScriptMessageHandler.
    /// - Parameters:
    ///   - delegate: Callback protocol to handle the message from the WebView
    ///   - hostMessageInterface: Message interface protocol of the host application
    func addMiniAppScriptMessageHandler(delegate: MiniAppCallbackDelegate, hostAppMessageDelegate: MiniAppMessageDelegate, miniAppId: String, miniAppTitle: String) {
        add(MiniAppScriptMessageHandler(delegate: delegate, hostAppMessageDelegate: hostAppMessageDelegate, miniAppId: miniAppId, miniAppTitle: miniAppTitle), name: Constants.javascriptInterfaceName)
    }

    /// Method to remove the custom WKScriptMessageHandler. Removing the message handler will help to avoid memory leaks
    func removeMessageHandler() {
        removeScriptMessageHandler(forName: Constants.javascriptInterfaceName)
    }

    /// Method to add the Bridging Javascript to the WebView User Controller
    /// This JavaScript is responsible for communication between SDK and Mini App
    /// Any request from Mini App is communicated via the contract available in the Bridging script
    func addBridgingJavaScript(podBundle: Bundle = Bundle(for: MiniApp.self)) {
        guard let javascriptPath = podBundle.path(forResource: "bridge", ofType: "js"),
            let javascriptSource = try? String(contentsOfFile: javascriptPath) else { return }

        let userScript = WKUserScript(source: javascriptSource, injectionTime: .atDocumentStart, forMainFrameOnly: true)
         addUserScript(userScript)
    }
}
