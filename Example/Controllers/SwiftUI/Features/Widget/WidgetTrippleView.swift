import SwiftUI
import MiniApp

class WidgetTrippleViewModel: ObservableObject {

    var interfaces: [String: MiniAppMessageDelegate] = [:]

    @Published var first: String
    @Published var second: String
    @Published var third: String

    init(first: String, second: String, third: String) {
        self.first = first
        self.second = second
        self.third = third
        interfaces[first] = MiniAppViewMessageDelegator(miniAppId: first)
        interfaces[second] = MiniAppViewMessageDelegator(miniAppId: second)
        interfaces[third] = MiniAppViewMessageDelegator(miniAppId: third)
    }

    func messageInterface(for miniAppId: String) -> MiniAppMessageDelegate {
        return interfaces[miniAppId] ?? MiniAppViewMessageDelegator()
    }
}

struct WidgetTrippleView: View {

    let viewModel: WidgetTrippleViewModel

    init(miniAppIdFirst: String = "", miniAppIdSecond: String = "", miniAppIdThird: String = "") {
        viewModel = WidgetTrippleViewModel(first: miniAppIdFirst, second: miniAppIdSecond, third: miniAppIdThird)
    }

    var body: some View {
        VStack {
            MiniAppSUIView(params:
                .init(
                        config: MiniAppConfig(
                            config: Config.current(),
                            messageDelegate: viewModel.messageInterface(for: viewModel.first)
                        ),
                        type: .widget,
                        appId: viewModel.first
                )
            )
            MiniAppSUIView(params:
                .init(
                    config: MiniAppConfig(
                        config: Config.current(),
                        messageDelegate: viewModel.messageInterface(for: viewModel.second)
                    ),
                    type: .widget,
                    appId: viewModel.second
                )
            )
            MiniAppSUIView(params:
                .init(
                    config: MiniAppConfig(
                        config: Config.current(),
                        messageDelegate: viewModel.messageInterface(for: viewModel.third)
                    ),
                    type: .widget,
                    appId: viewModel.third
                )
            )
        }
        .padding(20)
        .navigationTitle("Three Widgets")
    }
}

struct WidgetTrippleView_Previews: PreviewProvider {
    static var previews: some View {
        WidgetTrippleView()
    }
}

class WidgetTrippleViewDelegator: MiniAppMessageDelegate {

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
