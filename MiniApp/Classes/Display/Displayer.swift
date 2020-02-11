internal class Displayer {

    func getMiniAppView(miniAppPath: URL?) -> MiniAppView? {
        guard let filePath = miniAppPath else {
            return nil
        }
        return RealMiniAppView.shared.getMiniAppView(miniAppPath: filePath)
    }
}
