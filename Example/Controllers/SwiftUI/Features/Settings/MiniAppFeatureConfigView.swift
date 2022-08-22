import SwiftUI

struct MiniAppFeatureConfigView: View {

    @ObservedObject var store: MiniAppStore

    @State var isPickerPresented: Bool = false

    var body: some View {
        Form {
            Section(header: Text("Single")) {
                MiniAppFeatureConfigIdCell(
                    store: store,
                    placeholder: "MiniApp Id",
                    miniAppId: store.$miniAppIdentifierSingle,
                    version: store.$miniAppVersionSingle
                )
            }
            Section(header: Text("Tripple")) {
                MiniAppFeatureConfigIdCell(
                    store: store,
                    placeholder: "MiniApp Id (1)",
                    miniAppId: store.$miniAppIdentifierTrippleFirst,
                    version: store.$miniAppVersionTrippleFirst
                )
                MiniAppFeatureConfigIdCell(
                    store: store,
                    placeholder: "MiniApp Id (2)",
                    miniAppId: store.$miniAppIdentifierTrippleSecond,
                    version: store.$miniAppVersionTrippleSecond
                )
                MiniAppFeatureConfigIdCell(
                    store: store,
                    placeholder: "MiniApp Id (3)",
                    miniAppId: store.$miniAppIdentifierTrippleThird,
                    version: store.$miniAppVersionTrippleThird
                )
            }
        }
        .font(.system(size: 13))
        .navigationTitle("Config")
    }
}

struct MiniAppFeatureConfigView_Previews: PreviewProvider {
    static var previews: some View {
        MiniAppFeatureConfigView(store: MiniAppStore.empty())
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
            .background(RoundedRectangle(cornerRadius: 10).fill(Color(uiColor: .secondarySystemBackground)))
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
