import Foundation

struct SettingsParams: Equatable {
    var tab: Int = 1
    var projectId: String = ""
    var subscriptionKey: String = ""
    var isProduction: Bool = false
    var isPreviewMode: Bool = false
}
