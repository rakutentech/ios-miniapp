import SwiftUI
import Combine

@MainActor
class MiniAppDashboardViewModel: ObservableObject {
    let store = MiniAppStore.shared
}

struct MiniAppDashboardView: View {

    @StateObject var viewModel = MiniAppDashboardViewModel()
    @StateObject var sharedSettingsVM: MiniAppSettingsViewModel

    @State var sampleMiniAppId: String = ""
    @State var sampleMiniAppVersion: String = ""
    @State var selection: Int = 0
    @State var isPresentingFullProgress: Bool = false

    var body: some View {
        ZStack {
            TabView(selection: $selection) {
                NavigationView {
                    MiniAppListView(type: .listI, title: NSLocalizedString("demo.app.rat.page.name.list.i", comment: ""))
                }
                .tabItem {
                    Label("List I", systemImage: "list.bullet")
                        .accessibilityIdentifier(AccessibilityIdentifiers.tabBarListI.identifier)
                }
                .tag(0)

                NavigationView {
                    MiniAppListView(type: .listII, title: NSLocalizedString("demo.app.rat.page.name.list.ii", comment: ""))
                }
                .tabItem {
                    Label("List II", systemImage: "list.bullet")
                        .accessibilityIdentifier(AccessibilityIdentifiers.tabBarListII.identifier)
                }
                .tag(1)

                NavigationView {
                    MiniAppFeatureListView()
                }
                .tabItem {
                    if #available(iOS 15, *) {
                        Label("Features", systemImage: "menucard")
                            .accessibilityIdentifier(AccessibilityIdentifiers.tabBarFeatures.identifier)
                    } else {
                        Label("Features", systemImage: "flag")
                            .accessibilityIdentifier(AccessibilityIdentifiers.tabBarFeatures.identifier)
                    }
                }
                .tag(2)

                NavigationView {
                    MiniAppSettingsView(viewModel: sharedSettingsVM, showFullProgress: $isPresentingFullProgress)
                }
                .navigationViewStyle(.stack)
                .tabItem {
                    Label("Settings", systemImage: "gear")
                        .accessibilityIdentifier(AccessibilityIdentifiers.tabBarSettings.identifier)
                }
                .tag(3)
            }

            if isPresentingFullProgress {
                Color.black
                    .ignoresSafeArea()
                    .opacity(0.5)
                    .overlay(ProgressView().foregroundColor(.white))
                    .animation(.spring())
            }
        }
        .navigationTitle(navigationTitle)
        .onAppear {
            if !viewModel.store.miniAppSetupCompleted {
                selection = 3
            }
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
            return "Settings"
        default:
            return "Unknown"
        }
    }
}

struct MiniAppDashboardView_Previews: PreviewProvider {
    static var previews: some View {
        MiniAppDashboardView(sharedSettingsVM: MiniAppSettingsViewModel())
    }
}
