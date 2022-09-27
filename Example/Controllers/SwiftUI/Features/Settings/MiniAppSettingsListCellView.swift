import SwiftUI

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

struct MiniAppSettingsListCellView_Previews: PreviewProvider {
    static var previews: some View {
        MiniAppSettingsListCellView(text: "General", image: Image(systemName: "gear"))
    }
}
