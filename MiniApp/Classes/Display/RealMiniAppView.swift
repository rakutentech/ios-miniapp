internal class RealMiniAppView {
    static let shared =  RealMiniAppView()

    func getMiniAppView(miniAppPath: URL) -> MiniAppDisplayProtocol? {
        return MiniAppView(filePath: miniAppPath)
    }
}
