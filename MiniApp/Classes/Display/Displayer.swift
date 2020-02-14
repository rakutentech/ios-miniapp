internal class Displayer {

    func getMiniAppView(miniAppPath: URL) -> MiniAppDisplayProtocol? {
        return RealMiniAppView.shared.getMiniAppView(miniAppPath: miniAppPath)
    }
}
