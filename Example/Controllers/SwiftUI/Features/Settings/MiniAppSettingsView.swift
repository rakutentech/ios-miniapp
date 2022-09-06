import SwiftUI
import UIKit

struct MiniAppSettingsView: View {

    @ObservedObject var store: MiniAppStore
    
    @StateObject var viewModel = MiniAppSettingsViewModel()

    @State private var isPickerPresented: Bool = false

    @State private var config: SettingsConfig = SettingsConfig(
        previewMode: .previewable,
        environmentMode: .production,
        listIProjectId: Config.getInfoPlistString(key: .projectId) ?? "",
        listISubscriptionKey: Config.getInfoPlistString(key: .subscriptionKey) ?? ""
        //listIIProjectId: Config.getInfoPlistString(key: .projectId) ?? "",
        //listIISubscriptionKey: Config.getInfoPlistString(key: .subscriptionKey) ?? ""
    )

    @State private var selectedListConfig: ListConfig = .listI

    var body: some View {
        Form {

            Section(header: Text("Preview Mode")) {
                Picker("Published", selection: $config.previewMode) {
                    ForEach(PreviewMode.allCases, id: \.self) { mode in
                        Text(mode.name).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.vertical, 15)
            }
            
            Section(header: Text("Environment")) {
                Picker("Environment", selection: $config.environmentMode) {
                    ForEach(EnvironmentMode.allCases, id: \.self) { mode in
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
                
                switch selectedListConfig {
                case .listI:
                    TextField("Project Id", text: $config.listIProjectId)
                        .padding(.vertical, 15)
                    TextField("Subscription Key", text: $config.listISubscriptionKey)
                        .padding(.vertical, 15)
                case .listII:
                    TextField("Project Id", text: $config.listIIProjectId)
                        .padding(.vertical, 15)
                    TextField("Subscription Key", text: $config.listIISubscriptionKey)
                        .padding(.vertical, 15)
                }
            }
            
            Section {
                ForEach(MenuItem.allCases, id: \.self) { item in
                    
                    switch item {
                    case .general:
                        NavigationLink(destination: MiniAppSettingsGeneralView(parameters: $config.queryParameters)) {
                            MiniAppSettingsListCellView(text: item.name, image: item.icon)
                        }
                    case .qa:
                        NavigationLink(destination: MiniAppSettingsQAView()) {
                            MiniAppSettingsListCellView(text: item.name, image: item.icon)
                        }
                    case .profile:
                        NavigationLink(destination: MiniAppSettingsProfileView()) {
                            MiniAppSettingsListCellView(text: item.name, image: item.icon)
                        }
                    case .contacts:
                        NavigationLink(destination: MiniAppSettingsContactsView()) {
                            MiniAppSettingsListCellView(text: item.name, image: item.icon)
                        }
                    case .accessToken:
                        NavigationLink(destination: MiniAppSettingsAccessTokenView()) {
                            MiniAppSettingsListCellView(text: item.name, image: item.icon)
                        }
                    case .points:
                        NavigationLink(destination: MiniAppSettingsPointsView()) {
                            MiniAppSettingsListCellView(text: item.name, image: item.icon)
                        }
                    case .signature:
                        NavigationLink(destination: MiniAppSettingsSignatureView()) {
                            MiniAppSettingsListCellView(text: item.name, image: item.icon)
                        }
                    }

                }
            }
            .font(.system(size: 16, weight: .medium))

            Text(viewModel.getBuildVersionText())
//            Section(header: Text("Single")) {
//                MiniAppFeatureConfigIdCell(
//                    store: store,
//                    placeholder: "MiniApp Id",
//                    miniAppId: store.$miniAppIdentifierSingle,
//                    version: store.$miniAppVersionSingle
//                )
//            }
//            Section(header: Text("Tripple")) {
//                MiniAppFeatureConfigIdCell(
//                    store: store,
//                    placeholder: "MiniApp Id (1)",
//                    miniAppId: store.$miniAppIdentifierTrippleFirst,
//                    version: store.$miniAppVersionTrippleFirst
//                )
//                MiniAppFeatureConfigIdCell(
//                    store: store,
//                    placeholder: "MiniApp Id (2)",
//                    miniAppId: store.$miniAppIdentifierTrippleSecond,
//                    version: store.$miniAppVersionTrippleSecond
//                )
//                MiniAppFeatureConfigIdCell(
//                    store: store,
//                    placeholder: "MiniApp Id (3)",
//                    miniAppId: store.$miniAppIdentifierTrippleThird,
//                    version: store.$miniAppVersionTrippleThird
//                )
//            }
        }
        .font(.system(size: 13))
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    viewModel.save(config: config)
                }
            }
        }
    }
}

struct MiniAppFeatureConfigView_Previews: PreviewProvider {
    static var previews: some View {
        MiniAppSettingsView(store: MiniAppStore.empty())
    }
}

extension MiniAppSettingsView {
    
    struct SettingsConfig: Hashable {
        var previewMode: PreviewMode
        var environmentMode: EnvironmentMode
        var listIProjectId: String = ""
        var listISubscriptionKey: String = ""
        var listIIProjectId: String = ""
        var listIISubscriptionKey: String = ""
        
        var queryParameters: String = ""
    }
    
    enum PreviewMode: CaseIterable {
        case previewable
        case published
        
        var name: String {
            switch self {
            case .previewable:
                return "Previewable"
            case .published:
                return "Published"
            }
        }
    }

    enum EnvironmentMode: CaseIterable {
        case production
        case staging
        
        var name: String {
            switch self {
            case .production:
                return "Production"
            case .staging:
                return "Staging"
            }
        }
    }

    enum ListConfig: CaseIterable {
        case listI
        case listII
        
        var name: String {
            switch self {
            case .listI:
                return "List I"
            case .listII:
                return "List II"
            }
        }
    }

    enum MenuItem: CaseIterable {
        case general
        case qa
        case profile
        case contacts
        case accessToken
        case points
        case signature
        
        var name: String {
            switch self {
            case .general:
                return "General"
            case .qa:
                return "QA"
            case .profile:
                return "Profile"
            case .contacts:
                return "Contacts"
            case .accessToken:
                return "Access Token"
            case .points:
                return "Points"
            case .signature:
                return "Signature"
            }
        }
    
        var icon: Image {
            switch self {
            case .general:
                return Image(systemName: "gear")
            case .qa:
                return Image(systemName: "person.2")
            case .profile:
                return Image(systemName: "person.crop.circle.fill")
            case .contacts:
                return Image(systemName: "person.3.fill")
            case .accessToken:
                return Image(systemName: "checkerboard.shield")
            case .points:
                return Image(systemName: "p.circle")
            case .signature:
                return Image(systemName: "lock.fill")
            }
        }
    }
}

struct MiniAppSettingsListCellView: View {
    
    @State var text: String
    @State var image: Image
    
    var body: some View {
        Label {
            Text(text)
        } icon: {
            image
            .font(.system(size: 16, weight: .bold))
            .foregroundColor(.red)
        }
        .padding(.vertical, 15)
    }
}

struct MiniAppFeatureConfigIdCell: View {

    @ObservedObject var store: MiniAppStore

    @State var placeholder: String
    @Binding var miniAppId: String
    @Binding var version: String
    @State var isPickerPresented: Bool = false

    var body: some View {
        HStack(spacing: 10) {
            VStack {
                TextField(placeholder, text: $miniAppId)
                    .frame(height: 30)
                    .frame(maxWidth: .infinity)
                TextField("Version", text: $version)
                    .frame(height: 30)
                    .frame(maxWidth: .infinity)
            }

            Button {
                isPickerPresented = true
            } label: {
                Image(systemName: "list.dash")
            }
            .frame(width: 50, height: 50)
            .background(RoundedRectangle(cornerRadius: 10).fill(Color(.secondarySystemBackground)))
            .sheet(isPresented: $isPickerPresented, content: {
                MiniAppListPickerView(
                    store: store,
                    isPresented: $isPickerPresented,
                    miniAppId: $miniAppId,
                    version: $version
                )
                .environmentObject(store)
            })
        }
        .padding(.vertical, 10)
    }
}
