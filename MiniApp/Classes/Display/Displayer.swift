internal class Displayer {

    func getMiniAppView(miniAppId: String, versionId: String, miniAppTitle: String, hostAppMessageDelegate: MiniAppMessageProtocol) -> MiniAppDisplayProtocol {
        return RealMiniAppView(miniAppId: miniAppId, versionId: versionId, miniAppTitle: miniAppTitle, hostAppMessageDelegate: hostAppMessageDelegate)
    }
}
