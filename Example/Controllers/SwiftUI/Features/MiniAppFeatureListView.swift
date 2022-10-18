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
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle("Features")
        .navigationBarTitleDisplayMode(.inline)
        .trackPage(pageName: "Features")
    }
}

struct MiniAppFeatureListView_Previews: PreviewProvider {
    static var previews: some View {
        MiniAppFeatureListView()
    }
}
