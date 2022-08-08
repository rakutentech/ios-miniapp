import SwiftUI
import Combine

struct MiniAppFeatureListView: View {
    
    let store = MiniAppWidgetStore()
    
    let dismiss = PassthroughSubject<Void, Error>()

    var miniAppIds: [String]
    
    @State var isSingleMiniAppActive: Bool = false
    
    var body: some View {
        List {
            Section("MiniApp") {
                if miniAppIds.count >= 1 {
                    NavigationLink(
                        destination: {
                            MiniAppSingleView(
                                miniAppId: store.$miniAppIdentifierSingle,
                                miniAppVersion: store.$miniAppVersionSingle,
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
                } else {
                    MiniAppFeatureListCell(
                        title: "Miniapp",
                        subTitle: "Displays a single MiniApp (disabled)",
                        active: false
                    )
                }
                
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
                
                if miniAppIds.count >= 1 {
                    NavigationLink(
                        destination: {
                            MiniAppSingleView(
                                miniAppId: store.$miniAppIdentifierSingle,
                                miniAppVersion: store.$miniAppVersionSingle,
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
                } else {
                    MiniAppFeatureListCell(
                        title: "Widget",
                        subTitle: "Displays a single Widget (disabled)",
                        active: false
                    )
                }
                
                if miniAppIds.count >= 3 {
                    NavigationLink(destination: MiniAppTrippleView(
                        miniAppIdFirst: miniAppIds[0],
                        miniAppIdSecond: miniAppIds[1],
                        miniAppIdThird: miniAppIds[2]
                    ).environmentObject(store), label: {
                        MiniAppFeatureListCell(
                            title: "Three Widgets",
                            subTitle: "Displays three Widgets",
                            active: true
                        )
                    })
                    NavigationLink(destination: WidgetListView(miniAppIds: miniAppIds), label: {
                        MiniAppFeatureListCell(
                            title: "Widget List",
                            subTitle: "A list with multiple miniapps as widgets",
                            active: true
                        )
                    })
                } else {
                    MiniAppFeatureListCell(
                        title: "Three MiniApps",
                        subTitle: "Displays three MiniApps",
                        active: false
                    )
                    MiniAppFeatureListCell(
                        title: "Widgets",
                        subTitle: "A list with multiple miniapps as widgets",
                        active: false
                    )
                }
            }

        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle("Features")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading, content: {
                Button(action: {
                    dismiss.send(())
                }, label: {
                    Image(systemName: "xmark")
                })
            })
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing, content: {
                NavigationLink(destination: MiniAppFeatureConfigView().environmentObject(store), label: {
                    Image(systemName: "gearshape")
                })
            })
        }
    }
}

struct MiniAppFeatureListView_Previews: PreviewProvider {
    static var previews: some View {
        MiniAppFeatureListView(miniAppIds: [])
            
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
