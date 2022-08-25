import Foundation
import SwiftUI

public struct MiniAppSUIView: UIViewRepresentable {

    var config: MiniAppConfig
    var type: MiniAppType
    var appId: String?
    var version: String?
    var queryParams: String?
    var url: URL?

    public init(params: MiniAppViewDefaultParams) {
        self.config = params.config
        self.type = params.type
        self.appId = params.appId
        self.version = params.version
        self.queryParams = params.queryParams
    }

    public init(params: MiniAppViewUrlParams) {
        self.config = params.config
        self.type = params.type
        self.url = params.url
        self.queryParams = params.queryParams
    }

    public func makeUIView(context: Context) -> MiniAppView {
        if let appId = appId {
            let view = MiniAppView(
                config: config,
                type: type,
                appId: appId,
                version: version,
                queryParams: queryParams
            )
            view.load { result in
                print(result)
            }
            return view
        } else if let url = url {
            let view = MiniAppView(
                config: config,
                type: type,
                url: url,
                queryParams: queryParams
            )
            view.load { result in
                print(result)
            }
            return view
        } else {
            fatalError()
        }
    }

    public func updateUIView(_ uiView: MiniAppView, context: Context) {
        // update
    }
}
