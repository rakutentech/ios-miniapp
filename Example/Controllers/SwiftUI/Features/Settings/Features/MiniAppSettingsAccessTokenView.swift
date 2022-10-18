import SwiftUI

struct MiniAppSettingsAccessTokenView: View {

    @ObservedObject var viewModel: MiniAppSettingsViewModel

    @State private var accessTokenErrorBehavior: ErrorBehavior = .normal
    @State private var accessTokenErrorString = ""
    @State private var accessTokenString: String = "ACCESS_TOKEN"
    @State private var expiryDate: Date = Date()
    @State private var alertMessage: MiniAppAlertMessage?

    var body: some View {
        List {

            Section(header: Text("Access Token Error Behavior")) {
                VStack {
                    Picker("Error Behavior", selection: $accessTokenErrorBehavior) {
                        ForEach(ErrorBehavior.allCases, id: \.self) { behavior in
                            Text(behavior.name).tag(behavior)
                        }
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: accessTokenErrorBehavior, perform: { behavior in
                        trackSegmentedTap(pageName: "Access Token", segmentTitle: behavior.name)
                    })

                    TextField("Custom error message", text: $accessTokenErrorString)
                    .textFieldStyle(MiniAppTextFieldStyle())
                }
                .padding(.vertical, 15)
            }

            Section(header: Text("Access Token / Expiry")) {
                VStack(alignment: .leading) {
                    TextField("Access Token", text: $accessTokenString)
                        .textFieldStyle(MiniAppTextFieldStyle())

                    Spacer().frame(height: 5)

                    DatePicker("Expiry", selection: $expiryDate, displayedComponents: .date)
                        .datePickerStyle(.graphical)
                }
                .padding(.top, 15)
            }

        }
        .navigationTitle("Access Token")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    trackButtonTap(pageName: "Access Token", buttonTitle: "Save")
                    viewModel.saveAccessTokenBehavior(behavior: accessTokenErrorBehavior)
                    viewModel.saveAccessTokenErrorString(text: accessTokenErrorString)
                    if viewModel.saveTokenDetails(accessToken: accessTokenString, date: expiryDate) {
                        alertMessage = MiniAppAlertMessage(title: "Info", message: "Access Token info saved")
                    } else {
                        alertMessage = MiniAppAlertMessage(title: "Error", message: "Error while saving Token Info")
                    }
                } label: {
                    Text("Save")
                }
                .alert(item: $alertMessage) { alert in
                    Alert(title: Text(alert.title), message: Text(alert.message), dismissButton: .default(Text("Ok")))
                }
            }
        }
        .onAppear {
            accessTokenErrorBehavior = viewModel.getAccessTokenBehavior()
            accessTokenErrorString = viewModel.getAccessTokenError()

            let tokenInfo = viewModel.retrieveAccessTokenInfo()
            accessTokenString = tokenInfo.tokenString
            expiryDate = tokenInfo.expiryDate
        }
        .trackPage(pageName: "Access Token")
    }
}

struct MiniAppSettingsAccessTokenView_Previews: PreviewProvider {
    static var previews: some View {
        MiniAppSettingsAccessTokenView(viewModel: MiniAppSettingsViewModel())
    }
}

extension MiniAppSettingsAccessTokenView {
    enum ErrorBehavior: String, CaseIterable {
        case normal = ""
        case authorization = "AUTHORIZATION"
        case unknown = "OTHER"

        var name: String {
            switch self {
            case .normal:
                return "Normal"
            case .authorization:
                return "Authorization"
            case .unknown:
                return "Unknown"
            }
        }
    }
}
