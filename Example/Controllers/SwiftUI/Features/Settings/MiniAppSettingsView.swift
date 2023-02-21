import SwiftUI
import UIKit
import MiniApp

// swiftlint:disable line_length

struct MiniAppSettingsView: View {

    @StateObject var viewModel = MiniAppSettingsViewModel()

    @Binding var showFullProgress: Bool

    @State private var isPickerPresented: Bool = false
    @State private var alertMessage: MiniAppAlertMessage?
    @State private var selectedListConfig: ListType = .listI

    @State private var tmpSubscriptionKey: String = ""
    @State private var tmpProjectKey: String = ""

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

            Section(header: Text("RAS")) {
                VStack {
                    Picker("List Config", selection: $viewModel.selectedListConfig) {
                        Text(ListType.listI.name).tag(ListType.listI)
                            .accessibilityIdentifier(AccessibilityIdentifiers.settingsRasListI.identifier)
                        Text(ListType.listII.name).tag(ListType.listII)
                            .accessibilityIdentifier(AccessibilityIdentifiers.settingsRasListII.identifier)
                    }
                    .pickerStyle(.segmented)
                    .padding(.vertical, 15)
                    .onChange(of: viewModel.selectedListConfig, perform: { config in
                        trackSegmentedTap(pageName: "Settings", segmentTitle: config.name)
                        dismissKeyboard()
                    })

                    switch viewModel.selectedListConfig {
                    case .listI:
                        if let error = viewModel.listConfigI.error {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("🛑 Something went wrong when loading the list. This list configuration will not be saved.")
                                Text(error.localizedDescription)
                                    .lineLimit(2)
                                    .font(.system(size: 11))
                            }
                        } else {
                            EmptyView()
                        }
                    case .listII:
                        if let error = viewModel.listConfigII.error {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("🛑 Something went wrong when loading the list. This list configuration will not be saved.")
                                Text(error.localizedDescription)
                                    .lineLimit(2)
                                    .font(.system(size: 11))
                            }
                        } else {
                            EmptyView()
                        }
                    }
                }

                Picker("Environment", selection: $viewModel.listConfig.environmentMode) {
                    ForEach(Config.Environment.allCases, id: \.self) { mode in
                        Text(mode.name).tag(mode)
                            .accessibilityIdentifier("\(AccessibilityIdentifiers.settingsRasEnvironment.identifier).\(mode.name)")
                    }
                }
                .pickerStyle(.segmented)
                .padding(.vertical, 15)

                Picker("Published", selection: $viewModel.listConfig.previewMode) {
                    ForEach(PreviewMode.allCases, id: \.self) { mode in
                        Text(mode.name).tag(mode)
                            .accessibilityIdentifier(AccessibilityIdentifiers.settingsRasMode.identifier + "." + mode.name)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.vertical, 15)

                TextField(
                    viewModel.listConfig.placeholderProjectId,
                    text: $tmpProjectKey,
                    onEditingChanged: { isEditing in
                        if isEditing {
                            tmpProjectKey = viewModel.listConfig.projectId ?? ""
                        } else {
                            self.tmpProjectKey = maskedString(of: tmpProjectKey)
                        }
                    },
                    onCommit: {
                        viewModel.listConfig.projectId = tmpProjectKey
                        self.tmpProjectKey = maskedString(of: tmpProjectKey)
                    }
                )
                    .padding(.vertical, 15)
                    .accessibilityIdentifier(AccessibilityIdentifiers.settingsHostId.identifier)
                    .onAppear {
                        self.tmpProjectKey = maskedString(of: viewModel.listConfig.projectId ?? "")
                    }
                TextField(
                    viewModel.listConfig.placeholderSubscriptionKey,
                    text: $tmpSubscriptionKey,
                    onEditingChanged: { isEditing in
                        if isEditing {
                            tmpSubscriptionKey = viewModel.listConfig.subscriptionKey ?? ""
                        } else {
                            self.tmpSubscriptionKey = maskedString(of: tmpSubscriptionKey)
                        }
                    }, onCommit: {
                        viewModel.listConfig.subscriptionKey = tmpSubscriptionKey
                        self.tmpSubscriptionKey = maskedString(of: tmpSubscriptionKey)
                    }
                )
                    .padding(.vertical, 15)
                    .accessibilityIdentifier(AccessibilityIdentifiers.settingsSubscriptionKey.identifier)
                    .onAppear {
                        self.tmpSubscriptionKey = maskedString(of: viewModel.listConfig.subscriptionKey ?? "")
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
        .navigationTitle(pageName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    trackButtonTap(pageName: pageName, buttonTitle: "Save")
                    dismissKeyboard()
                    viewModel.save()
                }
                .disabled((viewModel.listConfig.wrappedProjectId.isEmpty || viewModel.listConfig.wrappedSubscriptionKey.isEmpty))
            }
        }
        .alert(item: $alertMessage) { errorMessage in
            Alert(
                title: Text(errorMessage.title),
                message: Text(errorMessage.message),
                dismissButton: .default(Text("Ok"))
            )
        }
        .onAppear {
            UITextField.appearance().clearButtonMode = .whileEditing
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
                if let error = error as? MASDKError, error.isQPSLimitError() {
                    alertMessage = MiniAppAlertMessage(
                        title: MASDKLocale.localize("miniapp.sdk.ios.error.title"),
                        message: MASDKLocale.localize("miniapp.sdk.ios.error.message.miniapp_too_many_requests_error")
                    )
                    return
                }
                if viewModel.listConfigI.error != nil && viewModel.listConfigII.error != nil {
                    alertMessage = MiniAppAlertMessage(title: "Error", message: "Something went wrong. Failed to load both lists.")
                } else if viewModel.listConfigI.error != nil {
                    alertMessage = MiniAppAlertMessage(title: "Error", message: "Something went wrong. Failed to load List I.")
                } else if viewModel.listConfigII.error != nil {
                    alertMessage = MiniAppAlertMessage(title: "Error", message: "Something went wrong. Failed to load List II.")
                }
            default:
                ()
            }
        }
        .onChange(of: viewModel.listConfig.environmentMode, perform: { _ in
            self.dismissKeyboard()
            switch viewModel.listConfig.environmentMode {
            case .production:
                viewModel.listConfig.projectId = viewModel.listConfig.projectIdProd
                viewModel.listConfig.subscriptionKey = viewModel.listConfig.subscriptionKeyProd

            case .staging:
                viewModel.listConfig.projectId = viewModel.listConfig.projectIdStaging
                viewModel.listConfig.subscriptionKey = viewModel.listConfig.subscriptionKeyStaging

            }
            self.tmpProjectKey = maskedString(of: viewModel.listConfig.projectId ?? "")
            self.tmpSubscriptionKey = maskedString(of: viewModel.listConfig.subscriptionKey ?? "")
        })
        .trackPage(pageName: pageName)
    }

    func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    var hasListIErrors: Bool {
        return viewModel.listConfigI.error != nil
    }

    var hasListIIErrors: Bool {
        return viewModel.listConfigII.error != nil
    }

    func maskedString(of keyString: String) -> String {
        if keyString.count > 5 {
            let startIndex = keyString.index(keyString.startIndex, offsetBy: 5)
            let endIndex = keyString.endIndex
            var str = keyString
            do {
                let regex = try NSRegularExpression(pattern: "([a-zA-Z0-9-])", options: .caseInsensitive)
                let range: Range<String.Index> = startIndex..<endIndex
                str = regex.stringByReplacingMatches(in: str, options: [], range: NSRange(range, in: str), withTemplate: "*")
            } catch { return str}
            return str
        }
        return keyString
    }
}

struct MiniAppAlertMessage: Identifiable {
    let id = UUID().uuidString
    let title: String
    let message: String
}

extension MiniAppSettingsView: ViewTrackable {
    var pageName: String {
        return NSLocalizedString("demo.app.rat.page.name.settings", comment: "")
    }
}

struct MiniAppFeatureConfigView_Previews: PreviewProvider {
    static var previews: some View {
        MiniAppSettingsView(showFullProgress: .constant(false))
    }
}
