import SwiftUI

struct MiniAppListRowCell: View {

    @State var iconUrl: URL?
    @State var displayName: String
    @State var versionTag: String
    @State var versionId: String
    
    var body: some View {
        HStack {
            VStack {
                Spacer()
                AsyncImage(url: iconUrl, content: { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 40, height: 40, alignment: .center)
                }, placeholder: {
                    Rectangle()
                        .fill(Color(.systemGray3))
                        .frame(width: 40, height: 40, alignment: .center)
                })
                Spacer()
            }


            VStack(spacing: 3) {
                HStack {
                    Text(displayName)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .lineLimit(1)
                    Spacer()
                }
                HStack {
                    Text(versionTag)
                        .font(.footnote)
                        .lineLimit(1)
                    Spacer()
                }
                HStack {
                    Text(versionId)
                        .font(.footnote)
                        .foregroundColor(Color(.secondaryLabel))
                        .lineLimit(1)
                    Spacer()
                }
            }
            .padding(10)
        }
    }
}

struct MiniAppListRowCell_Previews: PreviewProvider {
    static var previews: some View {
        MiniAppListRowCell(
            displayName: "MiniApp Sample",
            versionTag: "0.7.2",
            versionId: "abcdefgh-12345678-abcdefgh-12345678"
        )
    }
}
