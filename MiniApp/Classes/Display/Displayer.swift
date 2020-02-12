internal class Displayer {

    func getMiniAppView(miniAppPath: URL) -> MiniAppView {
        return RealMiniAppView.shared.getMiniAppView(miniAppPath: miniAppPath)
    }
}
