import SwiftUI

struct MiniAppTermsOptionalCell: View {

	@State var pageName: String?
    @State var name: String
    @State var description: String?
    @Binding var isAccepted: Bool

    var body: some View {
        Toggle(
            isOn: $isAccepted,
            label: {
                VStack(spacing: 5) {
                    HStack(spacing: 5) {
                        Text(name)
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
        })
        .toggleStyle(SwitchToggleStyle(tint: Color.red)) // .tint(.red)
        .padding(5)
		.onChange(of: isAccepted, perform: { newValue in
			trackToggleTap(pageName: pageName, toggleTitle: name, isOn: newValue)
		})
		.trackCell(pageName: pageName, cellTitle: name)
    }
}

struct MiniAppTermsOptionalCell_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MiniAppTermsOptionalCell(
                name: "Contacts",
                description: "Enter a description here...",
                isAccepted: .constant(true)
            )
            .previewLayout(.fixed(width: 400, height: 60))

            MiniAppTermsOptionalCell(
                name: "Contacts",
                description: "Enter a description here...",
                isAccepted: .constant(true)
            )
            .preferredColorScheme(.dark)
            .previewLayout(.fixed(width: 400, height: 60))
        }
    }
}
