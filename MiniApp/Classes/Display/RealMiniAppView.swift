internal class RealMiniAppView {
    static let shared =  RealMiniAppView()

    func getMiniAppView(miniAppId: String, messageInterface: MiniAppMessageProtocol) -> MiniAppDisplayProtocol? {
        return MiniAppView(miniAppId: miniAppId, messageInterface: messageInterface)
    }
}
