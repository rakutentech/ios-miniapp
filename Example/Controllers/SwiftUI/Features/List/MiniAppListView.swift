import SwiftUI
import MiniApp

struct MiniAppListView: View {
    
    @StateObject var viewModel = MiniAppListViewModel()

    @State private var miniAppInfo: MiniAppSingleViewRequest? = nil
    
    var body: some View {
        ZStack {
            if viewModel.indexedMiniAppInfoList.isEmpty {
                ProgressView()
            } else {
                List {
                    ForEach(viewModel.indexedMiniAppInfoList.keys.sorted(), id: \.self) { (key) in
                        Section(key) {
                            ForEach(viewModel.indexedMiniAppInfoList[key]!, id: \.version) { (info) in
                                MiniAppListRowCell(
                                    iconUrl: info.icon,
                                    displayName: info.displayName ?? "",
                                    versionTag: info.version.versionTag,
                                    versionId: info.version.versionId
                                )
                                .onTapGesture {
                                    miniAppInfo = MiniAppSingleViewRequest(info: info)
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
                    miniAppId: request.info.id,
                    miniAppVersion: request.info.version.versionId,
                    miniAppType: .miniapp
                )
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            miniAppInfo = nil
                        } label: {
                            Text("Close")
                        }
                    }
                }
            }
        }
    }
}

struct MiniAppListView_Previews: PreviewProvider {
    static var previews: some View {
        MiniAppListView()
    }
}

struct MiniAppSingleViewRequest: Identifiable {
    let id = UUID()
    let info: MiniAppInfo
}
