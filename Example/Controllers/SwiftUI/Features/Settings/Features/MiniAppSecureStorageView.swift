import SwiftUI

struct MiniAppSecureStorageView: View {
    
    @ObservedObject var viewModel: MiniAppSettingsViewModel

    @State private var miniAppWipeAppId = ""
    @State private var miniAppMaxStorageSize = ""

    @State private var alertMessage: MiniAppAlertMessage?

    var body: some View {
        Form {

            Section(header: Text("Secure Storage")) {
                VStack(spacing: 10) {
                    Button {
                        trackButtonTap(pageName: pageName, buttonTitle: "Wipe Secure Storages")
                        viewModel.clearSecureStorages()
                        alertMessage = MiniAppAlertMessage(title: "Success", message: "All stores were wiped successfully!")
                    } label: {
                        Text("Wipe Secure Storages")
                            .font(.system(size: 15, weight: .bold))
                            .frame(height: 50)
                            .frame(maxWidth: .infinity)
                    }
                    .foregroundColor(.white)
                    .background(Color("Crimson").cornerRadius(10))

                    HStack {
                        TextField("MiniApp ID", text: $miniAppWipeAppId)
                            .frame(height: 50)
                            .textFieldStyle(MiniAppTextFieldStyle())
                            .font(.system(size: 13))
                        Button {
                            trackButtonTap(pageName: pageName, buttonTitle: "Wipe Secure Storage")
                            viewModel.clearSecureStorage(appId: miniAppWipeAppId)
                            alertMessage = MiniAppAlertMessage(title: "Success", message: "MiniApp Storage cleared!")
                        } label: {
                            Image(systemName: "trash")
                        }
                        .foregroundColor(.red)
                        .disabled(miniAppWipeAppId.isEmpty)
                    }

                    HStack {
                        TextField("Max Storage Limit (Bytes)", text: $miniAppMaxStorageSize)
                            .frame(height: 50)
                            .textFieldStyle(MiniAppTextFieldStyle())
                            .font(.system(size: 13))
                            .keyboardWithCustomNumberPad()
                        Button {
                            trackButtonTap(pageName: pageName, buttonTitle: "Save Max Storage Limit")
                            switch viewModel.setSecureStorageLimit(maxSize: miniAppMaxStorageSize) {
                            case let .success(formattedString):
                                dismissKeyboard()
                                miniAppMaxStorageSize = formattedString
                                alertMessage = MiniAppAlertMessage(title: "Success", message: "Saved Max Storage Size Limit to \(formattedString) bytes.")
                            case let .failure(error):
                                alertMessage = MiniAppAlertMessage(title: error.title, message: error.message)
                            }
                        } label: {
                            Image(systemName: "square.and.arrow.down")
                        }
                        .foregroundColor(.red)
                        .disabled(miniAppMaxStorageSize.isEmpty)
                    }
                }
                .buttonStyle(.plain)
                .padding(.vertical, 15)
            }
        }
        .navigationTitle(pageName)
        .alert(item: $alertMessage) { alert in
            Alert(title: Text(alert.title), message: Text(alert.message), dismissButton: .default(Text("Ok")))
        }
        .onAppear {
            miniAppMaxStorageSize = viewModel.getSecureStorageMaxSize()
        }
        .trackPage(pageName: pageName)
    }
}

extension MiniAppSecureStorageView: ViewTrackable {
    var pageName: String {
        return NSLocalizedString("demo.app.rat.page.name.securestorage", comment: "")
    }
}

struct MiniAppSecureStorageView_Previews: PreviewProvider {
    static var previews: some View {
        MiniAppSecureStorageView(viewModel: MiniAppSettingsViewModel())
    }
}
