internal class Displayer {

    func getMiniAppView(miniAppId: String) -> MiniAppDisplayProtocol? {
        return RealMiniAppView(miniAppId: miniAppId)
    }
}
