import SwiftUI
import UIKit
import MiniApp

// swiftlint:disable line_length

struct MiniAppSettingsView: View {

    @StateObject var viewModel = MiniAppSettingsViewModel()

    @Binding var showFullProgress: Bool

    @State private var isPickerPresented: Bool = false
    @State private var alertMessage: MiniAppAlertMessage?
    @State private var selectedListConfig: ListConfig = .listI
    
    var body: some View {
        Form {

            if !viewModel.store.miniAppSetupCompleted {
                HStack {
                    VStack {
                        Image(systemName: "info.circle")
                            .foregroundColor(.red)
                            .font(.system(size: 15, weight: .bold))
                        Spacer()
                    }
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Welcome to MiniApp SDK Demo App.")
                            .font(.system(size: 15, weight: .bold))
                        Text("Start by entering the RAS credentials. You can enter the ProjectId and SubscriptionKey for List I and/or for List II and tap Save. Additional details can be configured in the list below the \"RAS\" Section.")
                    }
                }
                .padding(.vertical, 15)
            }

            Section(header: Text("Preview Mode")) {
                Picker("Published", selection: $viewModel.config.previewMode) {
                    ForEach(PreviewMode.allCases, id: \.self) { mode in
                        Text(mode.name).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.vertical, 15)
            }

            Section(header: Text("Environment")) {
                Picker("Environment", selection: $viewModel.config.environmentMode) {
                    ForEach(NewConfig.Environment.allCases, id: \.self) { mode in
                        Text(mode.name).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.vertical, 15)
            }

            Section(header: Text("RAS")) {
                Picker("List Config", selection: $selectedListConfig) {
                    ForEach(ListConfig.allCases, id: \.self) { config in
                        Text(config.name).tag(config)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.vertical, 15)

                switch viewModel.config.environmentMode {
                case .production:
                    switch selectedListConfig {
                    case .listI:
                        TextField(viewModel.config.listIProjectIdPlaceholder, text: $viewModel.config.listIProjectId)
                            .padding(.vertical, 15)
                        TextField(viewModel.config.listISubscriptionKeyPlaceholder, text: $viewModel.config.listISubscriptionKey)
                            .padding(.vertical, 15)
                    case .listII:
                        TextField(viewModel.config.listIProjectIdPlaceholder, text: $viewModel.config.listIIProjectId)
                            .padding(.vertical, 15)
                        TextField(viewModel.config.listISubscriptionKeyPlaceholder, text: $viewModel.config.listIISubscriptionKey)
                            .padding(.vertical, 15)
                    }
                case .staging:
                    switch selectedListConfig {
                    case .listI:
                        TextField("Project Id", text: $viewModel.config.listIStagingProjectId)
                            .padding(.vertical, 15)
                        TextField("Subscription Key", text: $viewModel.config.listIStagingSubscriptionKey)
                            .padding(.vertical, 15)
                    case .listII:
                        TextField("Project Id", text: $viewModel.config.listIIStagingProjectId)
                            .padding(.vertical, 15)
                        TextField("Subscription Key", text: $viewModel.config.listIIStagingSubscriptionKey)
                            .padding(.vertical, 15)
                    }
                }

            }

            Section {
                ForEach(MenuItem.allCases, id: \.self) { item in

                    switch item {
                    case .general:
                        NavigationLink(destination: MiniAppSettingsGeneralView(viewModel: viewModel)) {
                            MiniAppSettingsListCellView(text: item.name, image: item.icon)
                        }
                    case .qaSecureStorage:
                        NavigationLink(destination: MiniAppSettingsQAView(viewModel: viewModel)) {
                            MiniAppSettingsListCellView(text: item.name, image: item.icon)
                        }
                    case .profile:
                        NavigationLink(destination: MiniAppSettingsProfileView(viewModel: viewModel)) {
                            MiniAppSettingsListCellView(text: item.name, image: item.icon)
                        }
                    case .contacts:
                        NavigationLink(destination: MiniAppSettingsContactsView(viewModel: viewModel)) {
                            MiniAppSettingsListCellView(text: item.name, image: item.icon)
                        }
                    case .accessToken:
                        NavigationLink(destination: MiniAppSettingsAccessTokenView(viewModel: viewModel)) {
                            MiniAppSettingsListCellView(text: item.name, image: item.icon)
                        }
                    case .points:
                        NavigationLink(destination: MiniAppSettingsPointsView(viewModel: viewModel)) {
                            MiniAppSettingsListCellView(text: item.name, image: item.icon)
                        }
                    case .signature:
                        NavigationLink(destination: MiniAppSettingsSignatureView(viewModel: viewModel)) {
                            MiniAppSettingsListCellView(text: item.name, image: item.icon)
                        }
                    }

                }
            }
            .font(.system(size: 16, weight: .medium))

            Text(viewModel.getBuildVersionText())
        }
        .font(.system(size: 13))
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    viewModel.save()
                }
                .disabled((viewModel.config.listIProjectId.isEmpty || viewModel.config.listISubscriptionKey.isEmpty))
            }
        }
        .alert(item: $alertMessage) { errorMessage in
            Alert(
                title: Text(errorMessage.title),
                message: Text(errorMessage.message),
                dismissButton: .default(Text("Ok"))
            )
        }
        .onReceive(viewModel.$state) { state in
            switch state {
            case .loading:
                withAnimation {
                    showFullProgress = true
                }
            case .success:
                showFullProgress = false
                alertMessage = MiniAppAlertMessage(
                    title: MASDKLocale.localize("miniapp.sdk.ios.param.save_title"),
                    message: MASDKLocale.localize("miniapp.sdk.ios.param.save_text")
                )
            case let .error(error):
                showFullProgress = false
                alertMessage = MiniAppAlertMessage(title: "Error", message: error.localizedDescription)
            default:
                ()
            }
        }
    }
}

struct MiniAppAlertMessage: Identifiable {
    let id = UUID().uuidString
    let title: String
    let message: String
}

struct MiniAppFeatureConfigView_Previews: PreviewProvider {
    static var previews: some View {
        MiniAppSettingsView(showFullProgress: .constant(false))
    }
}
