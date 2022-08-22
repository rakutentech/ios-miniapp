import SwiftUI
import Combine

struct MiniAppDashboardView: View {

    @StateObject var store = MiniAppStore()

    @State var sampleMiniAppId: String = ""
    @State var sampleMiniAppVersion: String = ""

    @State var selection: Int = 0

    var body: some View {
        TabView(selection: $selection) {
            MiniAppListView()
            .tabItem {
                Label("List", systemImage: "list.bullet")
            }
            .tag(0)

            MiniAppFeatureListView(store: store)
            .tabItem {
                if #available(iOS 15, *) {
                    Label("Features", systemImage: "menucard")
                } else {
                    Label("Features", systemImage: "flag")
                }
            }
            .tag(1)

            MiniAppSingleView(
                miniAppId: sampleMiniAppId,
                miniAppVersion: sampleMiniAppVersion,
                miniAppType: .miniapp
            )
            .tabItem {
                Label("Sample", systemImage: "cube")
            }
            .tag(2)

            MiniAppFeatureConfigView(store: store)
            .tabItem {
                Label("Settings", systemImage: "gear")
            }
            .tag(3)
        }
        .navigationTitle(navigationTitle)
        .onAppear {
            store.load()
        }
    }

    var navigationTitle: String {
        switch selection {
        case 0:
            return "MiniApp List"
        case 1:
            return "MiniApp Features"
        case 2:
            return "MiniApp Sample"
        case 3:
            return "Settings"
        default:
            return "Unknown"
        }
    }
}

struct MiniAppDashboardView_Previews: PreviewProvider {
    static var previews: some View {
        MiniAppDashboardView()
    }
}
