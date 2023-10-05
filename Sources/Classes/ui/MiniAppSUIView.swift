import Foundation
import SwiftUI
import Combine

/// MiniAppView's convenience SwiftUI view wrapper
public struct MiniAppSUIView: UIViewRepresentable {

    @ObservedObject var handler: MiniAppSUIViewHandler

    var params: MiniAppViewParameters
    var fromCache: Bool = false
    var fromBundle: Bool = false

    // This parameter will be used for loadFromBundle only
    var miniAppManifest: MiniAppManifest?

    public init(params: MiniAppViewParameters.DefaultParams, fromCache: Bool = false, handler: MiniAppSUIViewHandler, fromBundle: Bool = false, miniAppManifest: MiniAppManifest? = nil) {
        var miniAppParams = params
        miniAppParams.fromBundle = fromBundle
        self.params = .default(miniAppParams)
        self.fromCache = fromCache
        self.handler = handler
        self.fromBundle = fromBundle
        self.miniAppManifest = miniAppManifest
    }

    public init(urlParams: MiniAppViewParameters.UrlParams) {
        self.params = .url(urlParams)
        self.handler = MiniAppSUIViewHandler()
    }

    public init(infoParams: MiniAppViewParameters.InfoParams, fromCache: Bool = false) {
        self.params = .info(infoParams)
        self.fromCache = fromCache
        self.handler = MiniAppSUIViewHandler()
    }

    public func makeUIView(context: Context) -> MiniAppView {
        let view = MiniAppView(params: params)
        view.progressStateView = MiniAppProgressView()
        if fromBundle {
            view.enable3DTouch = false
            view.loadFromBundle(miniAppManifest: miniAppManifest) {_ in
                self.handler.isActive = true
            }
        } else {
            view.load(fromCache: fromCache) { _ in
                self.handler.isActive = true
            }
        }
        context.coordinator.onGoBack = {
            _ = view.miniAppNavigationBar(didTriggerAction: .back)
        }
        context.coordinator.onGoForward = {
            _ = view.miniAppNavigationBar(didTriggerAction: .forward)
        }
        handler.closeAlertInfo  = {
            return view.alertInfo
        }
        handler.miniAppTitle  = {
            return view.miniAppTitle
        }
        handler.miniAppIdentifier = {
            return view.miniAppHandler.appId
        }
        handler.sendJsonToMiniApp = { jsonStr in
            view.sendJsonToMiniApp(string: jsonStr)
        }
        return view
    }

    public func updateUIView(_ uiView: MiniAppView, context: Context) {
        // update view if necessary
    }

    public func makeCoordinator() -> MiniAppSUIView.Coordinator {
        Coordinator(handler: handler)
    }
}

// MARK: - Coordinator
extension MiniAppSUIView {
    public class Coordinator: NSObject, ObservableObject {
        @ObservedObject var handler: MiniAppSUIViewHandler
        var bag = Set<AnyCancellable>()

        var onGoBack: (() -> Void)?
        var onGoForward: (() -> Void)?

        init(handler: MiniAppSUIViewHandler) {
            self.handler = handler
            super.init()
            handler
                .$action
                .debounce(for: 0.01, scheduler: RunLoop.main)
                .sink { [weak self] action in
                    guard let action = action else { return }
                    MiniAppLogger.d("MiniAppSUIView - action: \(action)")
                    switch action {
                    case .goBack:
                        self?.onGoBack?()
                    case .goForward:
                        self?.onGoForward?()
                    }
                }
                .store(in: &bag)
        }
    }
}

// MARK: - Handler
public class MiniAppSUIViewHandler: ObservableObject {

    @Published public var action: MiniAppSUIViewAction?

    @Published public var isActive: Bool = false

    public var closeAlertInfo: (() -> CloseAlertInfo?)?
    public var miniAppTitle: (() -> String)?
    public var miniAppIdentifier: (() -> String)?
    public var sendJsonToMiniApp: ((String) -> Void)?

    public init() {}
}

// MARK: - Action
public enum MiniAppSUIViewAction {
    case goBack
    case goForward
}
