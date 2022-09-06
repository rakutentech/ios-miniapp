import SwiftUI
import MiniApp

struct MiniAppListView: View {

    @StateObject var viewModel = MiniAppListViewModel()

    @State var title: String
    @State private var miniAppInfo: MiniAppSingleViewRequest?

    var body: some View {
        ZStack {
            switch viewModel.state {
            case .none, .loading:
                ProgressView()
            case .success:
                List {
                    ForEach(viewModel.indexedMiniAppInfoList.keys.sorted(), id: \.self) { (key) in
                        Section(header: Text(key)) {
                            ForEach(viewModel.indexedMiniAppInfoList[key]!, id: \.version) { (info) in
                                NavigationLink {
                                    MiniAppSingleView(
                                        miniAppId: info.id,
                                        miniAppVersion: info.version.versionId,
                                        miniAppType: .miniapp
                                    )
                                } label: {
                                    MiniAppListRowCell(
                                        iconUrl: info.icon,
                                        displayName: info.displayName ?? "",
                                        versionTag: info.version.versionTag,
                                        versionId: info.version.versionId
                                    )
                                }

                                //.onTapGesture {
                                //    miniAppInfo = MiniAppSingleViewRequest(info: info)
                                //}
                            }
                        }
                    }
                }
                .listStyle(GroupedListStyle())
            }
        }
        .navigationTitle(title)
        //.navigationBarTitleDisplayMode(.inline)
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
        MiniAppListView(title: "List I")
    }
}

struct MiniAppSingleViewRequest: Identifiable {
    let id = UUID()
    let info: MiniAppInfo
}
