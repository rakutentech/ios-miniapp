import Foundation
import SwiftUI

/// MiniAppView's convenience SwiftUI view wrapper
public struct MiniAppSUIView: UIViewRepresentable {

    var params: MiniAppViewParameters

    public init(params: MiniAppViewParameters) {
        self.params = params
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
