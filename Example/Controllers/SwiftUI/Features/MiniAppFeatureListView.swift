import SwiftUI
import Combine

struct MiniAppFeatureListView: View {
    
    @ObservedObject var store = MiniAppWidgetStore()
    @ObservedObject var permStore = MiniAppPermissionStore()

    @State var isSingleMiniAppActive: Bool = false
    
    var body: some View {
        List {
            Section("MiniApp") {
                NavigationLink(
                    destination: {
                        MiniAppSingleView(
                            miniAppId: store.$miniAppIdentifierSingle,
                            miniAppVersion: Binding<String?>(get: { store.miniAppVersionSingle }, set: { _ in }),
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
                
                NavigationLink(destination: MiniAppSegmentedView().environmentObject(store), label: {
                    MiniAppFeatureListCell(
                        title: "Segmented",
                        subTitle: "Open segmented miniapps",
                        active: true
                    )
                })

                NavigationLink(destination: MiniAppUrlView(), label: {
                    MiniAppFeatureListCell(
                        title: "URL",
                        subTitle: "Open a miniapp via url",
                        active: true
                    )
                })
            }

            Section("Widgets") {
                
                NavigationLink(
                    destination: {
                        MiniAppSingleView(
                            miniAppId: store.$miniAppIdentifierSingle,
                            miniAppVersion: Binding<String?>(get: { store.miniAppVersionSingle }, set: { _ in }),
                            miniAppType: .widget
                        )
                            .environmentObject(store)
                    },
                    label: {
                    MiniAppFeatureListCell(
                        title: "Widget",
                        subTitle: "Displays a single Widget",
                        active: true
                    )
                })
                
                NavigationLink(destination: MiniAppTrippleView(
                    miniAppIdFirst: store.miniAppVersionTrippleFirst,
                    miniAppIdSecond: store.miniAppVersionTrippleSecond,
                    miniAppIdThird: store.miniAppVersionTrippleThird
                ).environmentObject(store), label: {
                    MiniAppFeatureListCell(
                        title: "Three Widgets",
                        subTitle: "Displays three Widgets",
                        active: true
                    )
                })
                NavigationLink(destination: WidgetListView(miniAppIds: store.miniAppInfoList.map({ $0.id })), label: {
                    MiniAppFeatureListCell(
                        title: "Widget List",
                        subTitle: "A list with multiple miniapps as widgets",
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
