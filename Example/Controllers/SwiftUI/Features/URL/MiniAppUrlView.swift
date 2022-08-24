import SwiftUI
import MiniApp

struct MiniAppUrlView: View {

    let delegator = MiniAppUrlViewDelegator()

    @State var url: String = ""
    @State var currentUrl: String = ""
    @State var isMiniAppLoading: Bool = false

    var body: some View {
        VStack {
            HStack(spacing: 20) {
                TextField("http://localhost:1337", text: $url)
                    .frame(height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 10).fill(Color(UIColor.secondarySystemBackground)).padding(.horizontal, -10)
                    )
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .font(.system(size: 13))

                Button(action: {
                    currentUrl = ""
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(250), execute: {
                        currentUrl = url
                    })
                }, label: {
                    Image(systemName: "goforward")
                })
                .frame(width: 50, height: 50)
                .background(
                    RoundedRectangle(cornerRadius: 10).fill(Color(UIColor.secondarySystemBackground))
                )
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 15)

            if currentUrl.isEmpty {
                Spacer()
                Text("No MiniApp Loaded")
                    .font(.system(size: 15))
                    .foregroundColor(Color(UIColor.secondaryLabel))
                Spacer()
            } else {
                MiniAppSUIView(params:
                    MiniAppViewUrlParams(
                        config: MiniAppConfig(
                            config: Config.current(),
                            messageInterface: delegator
                        ),
                        type: .miniapp,
                        url: URL(string: url)!
                    )
                )
            }
        }
        .navigationTitle("MiniApp (URL)")
    }
}

struct MiniAppUrlView_Previews: PreviewProvider {
    static var previews: some View {
        MiniAppUrlView()
    }
}

class MiniAppUrlViewDelegator: MiniAppMessageDelegate {

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
