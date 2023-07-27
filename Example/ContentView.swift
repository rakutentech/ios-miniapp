import SwiftUI

struct ContentView: View {
    @StateObject var sharedSettingsVM: MiniAppSettingsViewModel

    var body: some View {
        MiniAppDashboardView(sharedSettingsVM: sharedSettingsVM)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(sharedSettingsVM: MiniAppSettingsViewModel())
    }
}
