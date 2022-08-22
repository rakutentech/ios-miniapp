import SwiftUI
import Combine

struct MiniAppFeatureListView: View {

    @StateObject var store: MiniAppStore

    @State var isSingleMiniAppActive: Bool = false

    var body: some View {
        List {
            Section("MiniApp") {
                NavigationLink(
                    destination: {
                        MiniAppSingleView(
                            miniAppId: store.miniAppIdentifierSingle,
                            miniAppVersion: store.miniAppVersionSingle,
                            miniAppType: .miniapp
                        )
                    },
                    label: {
                    MiniAppFeatureListCell(
                        title: "Miniapp",
                        subTitle: "Displays a single MiniApp",
                        active: true
                    )
                })

                NavigationLink(destination: MiniAppSegmentedView(), label: {
                    MiniAppFeatureListCell(
                        title: "Segmented",
                        subTitle: "Open segmented miniapps",
                        active: true
                    )
                })
            }

            Section("Widgets") {
                NavigationLink {
                    MiniAppSingleView(
                        miniAppId: store.miniAppIdentifierSingle,
                        miniAppVersion: store.miniAppVersionSingle,
                        miniAppType: .widget
                    )
                } label: {
                    MiniAppFeatureListCell(
                        title: "Widget",
                        subTitle: "Displays a single Widget",
                        active: true
                    )
                }

                NavigationLink {
                    WidgetTrippleView(
                        miniAppIdFirst: store.miniAppIdentifierTrippleFirst,
                        miniAppIdSecond: store.miniAppIdentifierTrippleSecond,
                        miniAppIdThird: store.miniAppIdentifierTrippleThird
                    )
                } label: {
                    MiniAppFeatureListCell(
                        title: "Three Widgets",
                        subTitle: "Displays three Widgets",
                        active: true
                    )
                }

                NavigationLink {
                    WidgetListView(miniAppIds: store.miniAppInfoList.map({ $0.id }))
                } label: {
                    MiniAppFeatureListCell(
                        title: "Widget List",
                        subTitle: "A list with multiple miniapps as widgets",
                        active: true
                    )
                }
            }

            Section("Testing") {
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
        MiniAppFeatureListView(store: MiniAppStore.empty())
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
                    .foregroundColor(Color(uiColor: UIColor.label))
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
