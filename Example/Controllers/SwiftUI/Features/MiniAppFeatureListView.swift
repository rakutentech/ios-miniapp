import SwiftUI
import Combine

struct MiniAppFeatureListView: View {

    //@StateObject var store: MiniAppStore

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
    }
}

struct MiniAppFeatureListView_Previews: PreviewProvider {
    static var previews: some View {
        MiniAppFeatureListView()
    }
}

struct MiniAppFeatureListCell: View {

    @State var title: String
    @State var subTitle: String
    @State var active: Bool

    var body: some View {
        VStack {
            HStack {
                Text(title)
                    .foregroundColor(Color(UIColor.label))
                    .fontWeight(.bold)
                Spacer()
            }
            .padding(EdgeInsets(top: 0, leading: 0, bottom: 5, trailing: 0))
            HStack {
                Text(subTitle)
                    .font(.footnote)
                    .foregroundColor(.secondary)
                Spacer()
            }
        }
        .padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
        .opacity(active ? 1 : 0.25)
    }
}
