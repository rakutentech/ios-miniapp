internal class Displayer {

    func getMiniAppView(miniAppId: String, messageInterface: MiniAppMessageProtocol) -> MiniAppDisplayProtocol? {
        return RealMiniAppView(miniAppId: miniAppId, messageInterface: messageInterface)
    }
}
