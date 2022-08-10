import SwiftUI
import MiniApp

struct MiniAppTrippleView: View {

    @EnvironmentObject var store: MiniAppWidgetStore

    let delegator = MiniAppTrippleViewDelegator()

    var miniAppIdFirst: String = ""
    var miniAppIdSecond: String = ""
    var miniAppIdThird: String = ""

    var body: some View {
        VStack {
            MiniAppSUView(params:
                MiniAppViewDefaultParams(
                    config: MiniAppNewConfig(
                        config: Config.current(),
                        messageInterface: delegator
                    ),
                    type: .miniapp,
                    appId: store.miniAppIdentifierTrippleFirst
                )
            )
            MiniAppSUView(params:
                MiniAppViewDefaultParams(
                    config: MiniAppNewConfig(
                        config: Config.current(),
                        messageInterface: delegator
                    ),
                    type: .miniapp,
                    appId: store.miniAppIdentifierTrippleSecond
                )
            )
            MiniAppSUView(params:
                MiniAppViewDefaultParams(
                    config: MiniAppNewConfig(
                        config: Config.current(),
                        messageInterface: delegator
                    ),
                    type: .miniapp,
                    appId: store.miniAppIdentifierTrippleThird
                )
            )
        }
        .navigationTitle("MiniApp (Tripple)")
    }
}

struct MiniAppTrippleView_Previews: PreviewProvider {
    static var previews: some View {
        MiniAppTrippleView()
    }
}

class MiniAppTrippleViewDelegator: MiniAppMessageDelegate {

    var miniAppId: String

    init(miniAppId: String = "") {
        self.miniAppId = miniAppId
    }

    func getUniqueId(completionHandler: @escaping (Result<String?, MASDKError>) -> Void) {
        completionHandler(.success("TestNew"))
    }

    func downloadFile(fileName: String, url: String, headers: DownloadHeaders, completionHandler: @escaping (Result<String, MASDKDownloadFileError>) -> Void) {
        //
    }

    func sendMessageToContact(_ message: MessageToContact, completionHandler: @escaping (Result<String?, MASDKError>) -> Void) {
        //
    }

    func sendMessageToContactId(_ contactId: String, message: MessageToContact, completionHandler: @escaping (Result<String?, MASDKError>) -> Void) {
        //
    }

    func sendMessageToMultipleContacts(_ message: MessageToContact, completionHandler: @escaping (Result<[String]?, MASDKError>) -> Void) {
        //
    }
}
