import SwiftUI
import MiniApp

struct MiniAppListView: View {

    @StateObject var viewModel: MiniAppListViewModel

    @State var title: String
    @State private var miniAppInfo: MiniAppSingleViewRequest?

    init(type: ListType, title: String) {
        _viewModel = StateObject(wrappedValue: MiniAppListViewModel(type: type))
        _title = State(wrappedValue: title)
    }

    var body: some View {
        ZStack {
            switch viewModel.state {
            case .none, .loading:
                ProgressView()
            case .awaitsSetup:
                VStack(spacing: 5) {
                    Image(systemName: "exclamationmark.triangle")
                        .foregroundColor(.orange)
                        .font(.system(size: 18, weight: .medium))
                    Text("Setup necessary")
                        .multilineTextAlignment(.center)
                        .font(.system(size: 18, weight: .medium))
                    Text("Go to settings and save your RAS configuration")
                        .multilineTextAlignment(.center)
                        .font(.system(size: 13))
                }
                .padding(.vertical, 20)
                .padding(.horizontal, 20)
                .background(RoundedRectangle(cornerRadius: 10).fill(Color(.secondarySystemBackground)))
                .padding(.horizontal, 40)
            case .success:
                if viewModel.indexedMiniAppInfoList.isEmpty {
                    Text("No MiniApps found")
                        .foregroundColor(Color(.secondaryLabel))
                } else {
                    MiniAppIndexedListView(viewModel: viewModel)
                }
            }
        }
        .navigationTitle(title)
        .sheet(item: $miniAppInfo) { request in
            NavigationView {
                MiniAppSingleView(
                    listType: viewModel.type,
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
        .trackPage(pageName: title)
    }
}

struct MiniAppListView_Previews: PreviewProvider {
    static var previews: some View {
        MiniAppListView(type: .listI, title: "List I")
    }
}

// MARK: - ViewTrackable
extension MiniAppListView: ViewTrackable {
    var pageName: String {
        return title
    }
}

struct MiniAppSingleViewRequest: Identifiable {
    let id = UUID()
    let info: MiniAppInfo
}

// MARK: - MiniAppIndexedListView
extension MiniAppListView {
	struct MiniAppIndexedListView: View {

		@ObservedObject var viewModel: MiniAppListViewModel
		@State private var searchText: String = ""

		var body: some View {
			VStack {
				TextField("Search... (id, version)", text: $viewModel.searchText)
					.textFieldStyle(MiniAppSearchTextFieldStyle())
					.padding(.vertical, 10)
					.padding(.horizontal, 16)
				List {
					ForEach(viewModel.filteredIndexedMiniAppInfoList.keys.sorted(), id: \.self) { (key) in
						Section(header: Text(key)) {
							ForEach(viewModel.filteredIndexedMiniAppInfoList[key]!, id: \.version) { (info) in
								NavigationLink {
									MiniAppSingleView(
										listType: viewModel.type,
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
							}
						}
					}
				}
				.listStyle(GroupedListStyle())
			}
		}
	}
}
