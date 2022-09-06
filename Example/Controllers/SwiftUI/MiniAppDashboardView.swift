import SwiftUI
import Combine

struct MiniAppDashboardView: View {

    @StateObject var store = MiniAppStore()

    @State var sampleMiniAppId: String = ""
    @State var sampleMiniAppVersion: String = ""

    @State var selection: Int = 0

    var body: some View {
        TabView(selection: $selection) {
            NavigationView {
                MiniAppListView(title: "List I")
            }
            .tabItem {
                Label("List I", systemImage: "list.bullet")
            }
            .tag(0)
            
            NavigationView {
                MiniAppListView(title: "List II")
            }
            .tabItem {
                Label("List II", systemImage: "list.bullet")
            }
            .tag(1)

            NavigationView {
                MiniAppFeatureListView(store: store)
            }
            .tabItem {
                if #available(iOS 15, *) {
                    Label("Features", systemImage: "menucard")
                } else {
                    Label("Features", systemImage: "flag")
                }
            }
            .tag(2)

//            MiniAppSingleView(
//                miniAppId: sampleMiniAppId,
//                miniAppVersion: sampleMiniAppVersion,
//                miniAppType: .miniapp
//            )
//            .tabItem {
//                Label("Sample", systemImage: "cube")
//            }
//            .tag(3)

            NavigationView {
                MiniAppSettingsView(store: store)
            }
            .navigationViewStyle(.stack)
            .tabItem {
                Label("Settings", systemImage: "gear")
            }
            .tag(4)
        }
        .navigationTitle(navigationTitle)
        .onAppear {
            store.load()
        }
    }

    var navigationTitle: String {
        switch selection {
        case 0:
            return "MiniApp List I"
        case 1:
            return "MiniApp List II"
        case 2:
            return "MiniApp Features"
        case 3:
            return "MiniApp Sample"
        case 4:
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
