internal class Displayer {

    func getMiniAppView(miniAppId: String) -> MiniAppDisplayProtocol? {
        return RealMiniAppView.shared.getMiniAppView(miniAppId: miniAppId)
    }
}
