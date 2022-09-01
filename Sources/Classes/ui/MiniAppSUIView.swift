import Foundation
import SwiftUI

public struct MiniAppSUIView: UIViewRepresentable {

    var params: MiniAppViewParameters

    public init(params: MiniAppView.DefaultParams) {
        self.params = .default(params)
    }

    public init(urlParams: MiniAppView.UrlParams) {
        self.params = .url(urlParams)
    }

    public func makeUIView(context: Context) -> MiniAppView {
        let view = MiniAppView(params: params)
        view.load { _ in
            // load finished
        }
        return view
    }

    public func updateUIView(_ uiView: MiniAppView, context: Context) {
        // update
    }
}