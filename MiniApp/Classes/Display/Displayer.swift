internal class Displayer {

    func getMiniAppView(miniAppId: String, versionId: String, hostAppMessageDelegate: MiniAppMessageProtocol) -> MiniAppDisplayProtocol {
        return RealMiniAppView(miniAppId: miniAppId, versionId: versionId, hostAppMessageDelegate: hostAppMessageDelegate)
    }
}
