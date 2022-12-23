import SwiftUI
import MiniApp

struct UniversalBridgeView: View {
    @ObservedObject var viewModel: MiniAppSettingsViewModel

    @State var textToSend: String = "{\\\"data\\\":\\\"This is a sample json information from host app.\\\"}"

    var body: some View {
        VStack {
            TextEditor(text: $textToSend)
                .padding()
                .frame(width: 300.0, height: 200)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color.red, lineWidth: 1)
                ).keyboardType(.alphabet)
                .padding()
            Button {
                dismissKeyboard()
                sendDataStringToMiniApp(textString: $textToSend.wrappedValue)
            } label: {
                Text("Send Data to MiniApp")
            }
        }
        .navigationTitle(pageName)
        .trackPage(pageName: pageName)
        .onTapGesture {
            dismissKeyboard()
        }
    }

    func sendDataStringToMiniApp(textString str: String) {
        for (_, handler) in viewModel.store.handlersListDict {
            handler.sendJsonToMiniApp?(str)
        }
    }
}

extension UniversalBridgeView: ViewTrackable {
    var pageName: String {
        return NSLocalizedString("demo.app.rat.page.name.universalbridge", comment: "")
    }
}

struct UniversalBridgeView_Previews: PreviewProvider {
    static var previews: some View {
        UniversalBridgeView(viewModel: MiniAppSettingsViewModel())
    }
}
