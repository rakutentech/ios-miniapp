import SwiftUI

struct MiniAppFeatureListCell: View {
    @State var title: String
    @State var subTitle: String
    @State var active: Bool

    var body: some View {
        VStack {
            HStack {
                Text(title)
                    .foregroundColor(Color(UIColor.label))
                    .fontWeight(.bold)
                Spacer()
            }
            .padding(EdgeInsets(top: 0, leading: 0, bottom: 5, trailing: 0))
            HStack {
                Text(subTitle)
                    .font(.footnote)
                    .foregroundColor(.secondary)
                Spacer()
            }
        }
        .padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
        .opacity(active ? 1 : 0.25)
    }
}

struct MiniAppFeatureListCell_Previews: PreviewProvider {
    static var previews: some View {
        MiniAppFeatureListCell(title: "Single MiniApp", subTitle: "This is a single MiniApp", active: true)
    }
}
