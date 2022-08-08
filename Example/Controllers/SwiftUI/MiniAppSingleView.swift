import SwiftUI
import MiniApp

struct MiniAppSingleView: View {

    let delegator: MiniAppViewDelegator
    
    @Binding var miniAppId: String
    @Binding var miniAppVersion: String
    @State var miniAppType: MiniAppType
    
    init(miniAppId: Binding<String>, miniAppVersion: Binding<String>, miniAppType: MiniAppType) {
        self._miniAppId = miniAppId
        self._miniAppVersion = miniAppVersion
        self.miniAppType = miniAppType
        self.delegator = MiniAppViewDelegator(miniAppId: miniAppId.wrappedValue)
    }
    
    var body: some View {
        MiniAppSUView(params:
            MiniAppViewDefaultParams(
                config: MiniAppNewConfig(
                    config: Config.current(),
                    adsDisplayer: nil,
                    messageInterface: delegator
                ),
                type: miniAppType,
                appId: miniAppId,
                version: miniAppVersion
            )
        )
        .navigationTitle("MiniApp")
    }
}

struct MiniAppSingleView_Previews: PreviewProvider {
    static var previews: some View {
        MiniAppSingleView(
            miniAppId: .constant(""),
            miniAppVersion: .constant(""),
            miniAppType: .miniapp
        )
    }
}
