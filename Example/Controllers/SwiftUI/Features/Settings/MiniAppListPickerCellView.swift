import SwiftUI

struct MiniAppListPickerCellView: View {

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

struct MiniAppListPickerCellView_Previews: PreviewProvider {
    static var previews: some View {
        MiniAppListPickerCellView(
            store: MiniAppStore(),
            placeholder: "Test",
            miniAppId: .constant("ABC-1234"),
            version: .constant("DEF-1234")
        )
    }
}
