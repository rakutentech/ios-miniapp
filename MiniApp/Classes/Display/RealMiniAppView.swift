internal class RealMiniAppView {
    static let shared =  RealMiniAppView()

    func getMiniAppView(miniAppId: String) -> MiniAppDisplayProtocol? {
        return MiniAppView(miniAppId: miniAppId)
    }
}
