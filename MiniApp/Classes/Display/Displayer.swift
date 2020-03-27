internal class Displayer {

    func getMiniAppView(miniAppId: String, messageInterface: MiniAppMessageProtocol) -> MiniAppDisplayProtocol? {
        return RealMiniAppView.shared.getMiniAppView(miniAppId: miniAppId, messageInterface: messageInterface)
    }
}
