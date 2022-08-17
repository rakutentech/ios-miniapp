import SwiftUI
import Combine

struct MiniAppDashboardView: View {

    @StateObject var store = MiniAppWidgetStore()

    @State var sampleMiniAppId: String = "404e46b4-263d-4768-b2ec-8a423224bead"
    @State var sampleMiniAppVersion: String = "206ca5bb-da16-4736-bc87-7c5890a50347"

    @State var selection: Int = 0
    
    var body: some View {
        TabView(selection: $selection) {
            MiniAppListView(store: store)
            .tabItem {
                Label("List", systemImage: "list.bullet")
            }
            .tag(0)

            MiniAppFeatureListView(store: store)
            .tabItem {
                Label("Features", systemImage: "menucard")
            }
            .tag(1)

            MiniAppSingleView(
                miniAppId: $sampleMiniAppId,
                miniAppVersion: Binding<String?>(get: { sampleMiniAppVersion }, set: { _ in }),
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
