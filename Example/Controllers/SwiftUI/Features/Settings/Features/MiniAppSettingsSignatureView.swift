import SwiftUI

struct MiniAppSettingsSignatureView: View {
    
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
        
    }
}

struct MiniAppSettingsSignatureView_Previews: PreviewProvider {
    static var previews: some View {
        MiniAppSettingsSignatureView()
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
