import SwiftUI
import MiniApp

struct MiniAppSettingsQAView: View {
    @ObservedObject var viewModel: MiniAppSettingsViewModel

    var body: some View {
        Form {
            NavigationLink {
                MiniAppSecureStorageView(viewModel: viewModel)
            } label: {
                Label("Secure Storage", systemImage: "questionmark.circle")
            }
            NavigationLink {
                UniversalBridgeView(viewModel: viewModel)
            } label: {
                Label("Universal Bridge", systemImage: "link")
            }
            NavigationLink {
                HostAppThemeColorsView(viewModel: viewModel)
            } label: {
                Label("Theme Colors", systemImage: "paintpalette")
            }
            NavigationLink {
                MAAnalyticsInfoView(analyticsData: NSLocalizedString("demo.app.analytics.info.loadingData", comment: ""))
            } label: {
                Label("Analytics Info", systemImage: "doc.plaintext")
            }
        }
        .navigationTitle(pageName)
        .trackPage(pageName: pageName)
    }
}

extension MiniAppSettingsQAView: ViewTrackable {
	var pageName: String {
		return NSLocalizedString("demo.app.rat.page.name.qa", comment: "")
	}
}

struct MiniAppSettingsQAView_Previews: PreviewProvider {
    static var previews: some View {
        MiniAppSettingsQAView(viewModel: MiniAppSettingsViewModel())
    }
}
