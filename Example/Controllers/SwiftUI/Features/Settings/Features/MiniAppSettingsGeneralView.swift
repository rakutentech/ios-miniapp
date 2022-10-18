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
        .navigationTitle("General")
        .trackPage(pageName: "General")
    }
}

struct MiniAppSettingsGeneralView_Previews: PreviewProvider {
    static var previews: some View {
        MiniAppSettingsGeneralView(viewModel: MiniAppSettingsViewModel())
    }
}

extension MiniAppSettingsGeneralView {

    struct QueryParametersView: View {

        @Environment(\.presentationMode) var presentationMode

        @State var parameters: String = ""

        @State var alertMessage: MiniAppAlertMessage?

        var body: some View {
            List {
                TextField("param1=value1&param2=value2", text: $parameters)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            }
            .navigationTitle("Query Parameters")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        trackButtonTap(pageName: "Query Parameters", buttonTitle: "Save")
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
                parameters = getQueryParam()
            }
            .trackPage(pageName: "Query Parameters")
        }

        func save() {
            if saveQueryParam(queryParam: parameters) {
                presentationMode.wrappedValue.dismiss()
            } else {
                //
            }
        }

    }

    struct DeepLinkView: View {

        @ObservedObject var viewModel: MiniAppSettingsViewModel

        @State var deepLinks: [String] = []

        @State private var newDeepLinkText: String = ""
        @State private var isAddPresented: Bool = false
        @State private var isDetailPresented: Bool = false

        var body: some View {
            List {
                ForEach($deepLinks, id: \.self) { deeplink in
                    Button {
                        isDetailPresented = true
                    } label: {
                        Text(deeplink.wrappedValue)
                    }
                    .sheet(isPresented: $isDetailPresented, content: {
                        NavigationView {
                            Form {
                                VStack(alignment: .leading) {
                                    Text("Please enter valid deep link")
                                        .font(.system(size: 13, weight: .medium))
                                    TextField("Deeplink", text: deeplink)
                                        .autocapitalization(.none)
                                }
                                .padding(.vertical, 15)
                            }
                            .navigationTitle("Deeplink")
                            .navigationBarTitleDisplayMode(.inline)
                            .toolbar {
                                ToolbarItem(placement: .navigationBarTrailing) {
                                    Button {
                                        isDetailPresented = false
                                        save()
                                    } label: {
                                        Text("Save")
                                    }
                                    .disabled(deeplink.wrappedValue.isEmpty)
                                }
                            }
                        }
                    })
                }
            }
            .navigationTitle("Deeplinks")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        trackButtonTap(pageName: "Settings", buttonTitle: "Add")
                        isAddPresented = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .sheet(isPresented: $isAddPresented, content: {
                        NavigationView {
                            Form {
                                VStack(alignment: .leading) {
                                    Text("Please enter valid deep link")
                                        .font(.system(size: 13, weight: .medium))
                                    TextField("Deeplink", text: $newDeepLinkText)
                                        .autocapitalization(.none)
                                }
                                .padding(.vertical, 15)
                            }
                            .navigationTitle("Deeplink")
                            .navigationBarTitleDisplayMode(.inline)
                            .toolbar {
                                ToolbarItem(placement: .navigationBarTrailing) {
                                    Button {
                                        trackButtonTap(pageName: "Deeplinks", buttonTitle: "Save")
                                        deepLinks.append(newDeepLinkText)
                                        isAddPresented = false
                                        save()
                                    } label: {
                                        Text("Save")
                                    }
                                    .disabled(newDeepLinkText.isEmpty)
                                }
                            }
                        }
                    })
                }
            }
            .onAppear {
                deepLinks = getDeepLinksList()
            }
            .trackPage(pageName: "Deeplinks")
        }

        func save() {
            viewModel.saveDeepLinkList(list: deepLinks)
        }

    }
}
