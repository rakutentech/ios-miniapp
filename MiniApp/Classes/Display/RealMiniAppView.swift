internal class RealMiniAppView {
    static let shared =  RealMiniAppView()

    func getMiniAppView(miniAppPath: URL) -> MiniAppView {
        let viewFrame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        return MiniAppView(filePath: miniAppPath, frame: viewFrame)
    }
}
