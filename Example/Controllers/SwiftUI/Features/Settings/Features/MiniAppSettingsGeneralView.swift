import SwiftUI

struct MiniAppSettingsGeneralView: View {

    @ObservedObject var viewModel: MiniAppSettingsViewModel

    var body: some View {
        Form {
            NavigationLink {
                QueryParametersView()
            } label: {
                Label("Query Parameters", systemImage: "questionmark.circle")
            }

            NavigationLink {
                DeepLinkView(viewModel: viewModel)
            } label: {
                Label("Deep Links", systemImage: "link")
            }
        }
        .navigationTitle(pageName)
        .trackPage(pageName: pageName)
    }
}

extension MiniAppSettingsGeneralView: ViewTrackable {
	var pageName: String {
		return NSLocalizedString("demo.app.rat.page.name.general", comment: "")
	}
}

struct MiniAppSettingsGeneralView_Previews: PreviewProvider {
    static var previews: some View {
        MiniAppSettingsGeneralView(viewModel: MiniAppSettingsViewModel())
    }
}

extension MiniAppSettingsGeneralView {

    struct QueryParametersView: View, ViewTrackable {

        @Environment(\.presentationMode) var presentationMode

        @State var parameters: String = ""

        @State var alertMessage: MiniAppAlertMessage?

        var body: some View {
            List {
                TextField("param1=value1&param2=value2", text: $parameters)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            }
            .navigationTitle(pageName)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        trackButtonTap(pageName: pageName, buttonTitle: "Save")
                        save()
                    } label: {
                        Text("Save")
                    }
                    .alert(item: $alertMessage) { message in
                        Alert(
                            title: Text(message.title),
                            message: Text(message.message),
                            dismissButton: .default(Text("Ok"))
                        )
                    }
                }
            }
            .onAppear {
                DispatchQueue.main.async {
                    parameters = getQueryParam()
                }
            }
            .trackPage(pageName: pageName)
        }

        func save() {
            if saveQueryParam(queryParam: parameters) {
                presentationMode.wrappedValue.dismiss()
            } else {
                //
            }
        }

		var pageName: String {
			return NSLocalizedString("demo.app.rat.page.name.queryparam", comment: "")
		}
    }

    struct DeepLinkView: View, ViewTrackable {

		@Environment(\.presentationMode) var presentationMode

        @ObservedObject var viewModel: MiniAppSettingsViewModel

        @State var deepLinks: [String] = []

        @State private var isAddPresented: Bool = false
		@State private var selectedIndex: Int?

        var body: some View {
            List {
				ForEach(deepLinks.indices, id: \.self) { index in
                    Button {
                        selectedIndex = index
                    } label: {
                        Text(deepLinks[index])
                    }
                }
				.onDelete { indexSet in
					deepLinks.remove(atOffsets: indexSet)
					save()
				}
            }
            .navigationTitle(pageName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        trackButtonTap(pageName: pageName, buttonTitle: "Add")
                        isAddPresented = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .sheet(isPresented: $isAddPresented, content: {
                        NavigationView {
							DeepLinkDetailView(deepLinks: $deepLinks, isPresented: $isAddPresented, deepLink: "") { new in
								deepLinks.append(new)
								save()
							}
                        }
                    })
                }
            }
			.sheet(item: $selectedIndex, content: { index in
				NavigationView {
					DeepLinkDetailView(
						deepLinks: $deepLinks,
						isPresented: Binding<Bool>(get: { selectedIndex != nil }, set: { new in if !new { selectedIndex = nil } }),
						deepLink: deepLinks[index]
					) { updated in
						deepLinks[index] = updated
						save()
					}
				}
			})
            .onAppear {
                deepLinks = getDeepLinksList()
            }
            .trackPage(pageName: pageName)
        }

        func save() {
            viewModel.saveDeepLinkList(list: deepLinks)
        }

		var pageName: String {
			return NSLocalizedString("demo.app.rat.page.name.deeplinks", comment: "")
		}
	}

	struct DeepLinkDetailView: View, ViewTrackable {

		@Binding var deepLinks: [String]
		@Binding var isPresented: Bool

		@State var deepLink: String = ""

		var onSave: (String) -> Void

		var body: some View {
			Form {
				VStack(alignment: .leading) {
					Text("Please enter valid deep link")
						.font(.system(size: 13, weight: .medium))
					TextField("Deeplink", text: $deepLink)
						.autocapitalization(.none)
				}
				.padding(.vertical, 15)
			}
			.navigationTitle(pageName)
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .navigationBarLeading) {
					CloseButton {
						trackButtonTap(pageName: pageName, buttonTitle: "Close")
						isPresented = false
					}
				}
				ToolbarItem(placement: .navigationBarTrailing) {
					Button {
						trackButtonTap(pageName: pageName, buttonTitle: "Save")
						onSave(deepLink)
						isPresented = false
					} label: {
						Text("Save")
					}
					.disabled(deepLink.isEmpty)
				}
			}
			.trackPage(pageName: pageName)
		}

		var pageName: String {
			return NSLocalizedString("demo.app.rat.page.name.deeplink", comment: "")
		}
	}
}
