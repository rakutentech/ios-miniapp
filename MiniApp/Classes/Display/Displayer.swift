internal class Displayer {

    func getMiniAppView(miniAppId: String, hostAppMessageDelegate: MiniAppMessageProtocol) -> MiniAppDisplayProtocol? {
        return RealMiniAppView(miniAppId: miniAppId, hostAppMessageDelegate: hostAppMessageDelegate)
    }
}
