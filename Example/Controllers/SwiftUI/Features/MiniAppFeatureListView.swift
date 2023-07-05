import SwiftUI
import Combine

struct MiniAppFeatureListView: View {

    @State var isSingleMiniAppActive: Bool = false

    var body: some View {
        List {
            Section(header: Text("Testing")) {
                NavigationLink(destination: MiniAppUrlView(), label: {
                    MiniAppFeatureListCell(
                        title: "URL",
                        subTitle: "Open a miniapp via url",
                        active: true
                    )
                })
                NavigationLink(destination: MiniAppFromBundle(), label: {
                    MiniAppFeatureListCell(
                        title: "Miniapp",
                        subTitle: "Open a miniapp from Bundle",
                        active: true
                    )
                })
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle(pageName)
        .navigationBarTitleDisplayMode(.inline)
        .trackPage(pageName: pageName)
    }
}

extension MiniAppFeatureListView: ViewTrackable {
	var pageName: String {
		return NSLocalizedString("demo.app.rat.page.name.features", comment: "")
	}
}

struct MiniAppFeatureListView_Previews: PreviewProvider {
    static var previews: some View {
        MiniAppFeatureListView()
    }
}
