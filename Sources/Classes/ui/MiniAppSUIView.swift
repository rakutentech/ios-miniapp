import Foundation
import SwiftUI

/// MiniAppView's convenience SwiftUI view wrapper
public struct MiniAppSUIView: UIViewRepresentable {

    var params: MiniAppViewParameters

    public init(params: MiniAppViewParameters.DefaultParams) {
        self.params = .default(params)
    }

    public init(urlParams: MiniAppViewParameters.UrlParams) {
        self.params = .url(urlParams)
    }

    public init(infoParams: MiniAppViewParameters.InfoParams) {
        self.params = .info(infoParams)
    }

    public func makeUIView(context: Context) -> MiniAppView {
        let view = MiniAppView(params: params)
        view.progressStateView = MiniAppProgressView()
        view.load { _ in
            // load finished
        }
        return view
    }

    public func updateUIView(_ uiView: MiniAppView, context: Context) {
        // update
    }
}
