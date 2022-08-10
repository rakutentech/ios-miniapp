import SwiftUI
import MiniApp

struct MiniAppListView: View {
    
    @ObservedObject var store: MiniAppWidgetStore

    @State var miniAppInfo: MiniAppSingleViewRequest? = nil
    
    var body: some View {
        ZStack {
            if store.indexedMiniAppInfoList.isEmpty {
                ProgressView()
            } else {
                List {
                    ForEach(store.indexedMiniAppInfoList.keys.sorted(), id: \.self) { (key) in
                        Section(key) {
                            ForEach(store.indexedMiniAppInfoList[key]!, id: \.version) { (info) in
                                HStack {
                                    VStack {
                                        Spacer()
                                        AsyncImage(url: info.icon, content: { image in
                                            image
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 40, height: 40, alignment: .center)
                                        }, placeholder: {
                                            Rectangle()
                                                .frame(width: 40, height: 40, alignment: .center)
                                        })
                                        Spacer()
                                    }


                                    VStack(spacing: 3) {
                                        HStack {
                                            Text((info.displayName ?? ""))
                                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                                .lineLimit(1)
                                            Spacer()
                                        }
                                        HStack {
                                            Text(info.version.versionTag)
                                                .font(.footnote)
                                                .lineLimit(1)
                                            Spacer()
                                        }
                                        HStack {
                                            Text(info.version.versionId)
                                                .font(.footnote)
                                                .foregroundColor(Color(.secondaryLabel))
                                                .lineLimit(1)
                                            Spacer()
                                        }
                                    }
                                    .padding(10)
                                    .onTapGesture {
                                        miniAppInfo = MiniAppSingleViewRequest(info: info)
                                    }
                                }
                            }
                        }
                    }
                }
                .listStyle(GroupedListStyle())
            }
        }
        .navigationTitle("MiniApp List")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $miniAppInfo) { request in
            NavigationView {
                MiniAppSingleView(
                    miniAppId: .constant(request.info.id),
                    miniAppVersion: .constant(request.info.version.versionId),
                    miniAppType: .miniapp
                )
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            miniAppInfo = nil
                        } label: {
                            Text("Cancel")
                        }
                    }
                }
            }
        }
    }
}

struct MiniAppListView_Previews: PreviewProvider {
    static var previews: some View {
        MiniAppListView(store: MiniAppWidgetStore())
    }
}

struct MiniAppSingleViewRequest: Identifiable {
    let id = UUID()
    let info: MiniAppInfo
}
