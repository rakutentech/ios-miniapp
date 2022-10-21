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
                .onChange(of: signatureMode, perform: { mode in
                    trackSegmentedTap(pageName: pageName, segmentTitle: mode.name)
                })
            }
        }
        .navigationTitle(pageName)
        .onAppear {
            signatureMode = viewModel.getSignature()
        }
        .onChange(of: signatureMode) { newValue in
            viewModel.saveSignature(mode: newValue)
        }
        .trackPage(pageName: pageName)
    }
}

extension MiniAppSettingsSignatureView: ViewTrackable {
	var pageName: String {
		return NSLocalizedString("demo.app.rat.page.name.signature.verification", comment: "")
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
