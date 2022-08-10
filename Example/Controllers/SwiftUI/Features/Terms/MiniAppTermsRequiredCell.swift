import SwiftUI

struct MiniAppTermsRequiredCell: View {
    
    @State var name: String
    @State var description: String?
    
    var body: some View {
        VStack(spacing: 5) {
            HStack(spacing: 5) {
                Text(name)
                Text("(Required)")
                    .foregroundColor(.red)
                Spacer()
            }
            if let description = description {
                HStack {
                    Text(description)
                        .foregroundColor(Color(.secondaryLabel))
                        .font(.footnote)
                    Spacer()
                }
            }
        }
        .padding(5)
    }
}

struct MiniAppTermsRequiredCell_Previews: PreviewProvider {
    static var previews: some View {
        MiniAppTermsRequiredCell(name: "User Name", description: "Enter a description here...")
    }
}
