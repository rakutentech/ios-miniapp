import Foundation
import SwiftUI
import MiniApp

extension View {
    func sendPauseMiniApp(miniAppId: String, version: String? = nil) {
        NotificationCenter.default.sendCustomEvent(
            MiniAppEvent.Event(
                miniAppId: miniAppId,
                miniAppVersion: version ?? "",
                type: .pause,
                comment: "MiniApp view will disappear"
            )
        )
    }
    func sendResumeMiniApp(miniAppId: String, version: String? = nil) {
        NotificationCenter.default.sendCustomEvent(
            MiniAppEvent.Event(
                miniAppId: miniAppId,
                miniAppVersion: version ?? "",
                type: .resume,
                comment: "MiniApp view will appear"
            )
        )
    }
}
