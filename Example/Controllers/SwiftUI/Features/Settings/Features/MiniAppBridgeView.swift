import SwiftUI
import MiniApp

struct MiniAppBridgeView: View {
    @ObservedObject var viewModel: MiniAppSettingsViewModel

    @State var textToSend:String = "{\"browsers\":{\"firefox\":{\"name\":\"Firefox\",\"pref_url\":\"about:config\",\"releases\":{\"1\":{\"release_date\":\"2004-11-09\",\"status\":\"retired\",\"engine\":\"Gecko\",\"engine_version\":\"1.7\"}}}}}"

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

    func sendDataStringToMiniApp(textString str:String) {
        for (_,handler) in viewModel.store.handlersListDict {
            handler.sendJsonStringToMiniApp?(str)
        }
    }
}

extension MiniAppBridgeView: ViewTrackable {
    var pageName: String {
        return NSLocalizedString("demo.app.rat.page.name.universalbridge", comment: "")
    }
}

struct MiniAppBridgeView_Previews: PreviewProvider {
    static var previews: some View {
        MiniAppBridgeView(viewModel: MiniAppSettingsViewModel())
    }
}
