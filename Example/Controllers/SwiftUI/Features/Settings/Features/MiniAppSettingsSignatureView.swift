import SwiftUI

struct MiniAppSettingsSignatureView: View {

    @ObservedObject var viewModel: MiniAppSettingsViewModel

    @State var signatureMode: SignatureMode = .plist

    var body: some View {
        List {
            Section(header: Text("Signature Verification Behavior")) {
                Picker("Error Behavior", selection: $signatureMode) {
                    ForEach(SignatureMode.allCases, id: \.self) { behavior in
                        Text(behavior.name).tag(behavior)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.vertical, 15)
            }
        }
        .navigationTitle("demo.app.rat.page.name.custom.signature.verification")
        .onAppear {
            signatureMode = viewModel.getSignature()
        }
        .onChange(of: signatureMode) { newValue in
            viewModel.saveSignature(mode: newValue)
        }
        .trackPage(pageName: "Signature")
    }
}

struct MiniAppSettingsSignatureView_Previews: PreviewProvider {
    static var previews: some View {
        MiniAppSettingsSignatureView(viewModel: MiniAppSettingsViewModel())
    }
}

extension MiniAppSettingsSignatureView {
    enum SignatureMode: CaseIterable {
        case plist
        case optional
        case mandatory

        var name: String {
            switch self {
            case .plist:
                return "Plist / Default"
            case .optional:
                return "Optional"
            case .mandatory:
                return "Mandatory"
            }
        }
    }
}
