internal class RealMiniAppView {
    static let shared =  RealMiniAppView()

    func getMiniAppView(miniAppPath: URL) -> MiniAppView {
        return MiniAppView(filePath: miniAppPath)
    }
}
