import SwiftUI
import MiniApp

struct UniversalBridgeView: View {
    @ObservedObject var viewModel: MiniAppSettingsViewModel

    @State var textToSend: String = "{\\\"data\\\":\\\"This is a sample json information from host app.\\\"}"

    var body: some View {
        VStack {
            TextEditor(text: $textToSend)
                .lineLimit(15)
                .frame(width: 300, height: 400, alignment: .top)
            Button {
                sendDataStringToMiniApp(textString: $textToSend.wrappedValue)
            } label: {
                Text("Send Data to MiniApp")
            }
        }
        .navigationTitle(pageName)
        .trackPage(pageName: pageName)
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