import Foundation
import SwiftUI

// swiftlint:disable identifier_name

struct MiniAppTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
        .frame(height: 50)
        .padding(.horizontal, 10)
        .background(
            RoundedRectangle(cornerRadius: 5, style: .continuous)
                .stroke(Color(.tertiaryLabel), lineWidth: 1)
        )
    }
}

struct MiniAppSearchTextFieldStyle: TextFieldStyle {
	func _body(configuration: TextField<Self._Label>) -> some View {
		HStack {
			Image(systemName: "magnifyingglass")
				.foregroundColor(.gray)
				.padding(.leading, 15)
			configuration
				.frame(height: 40)
				.padding(.trailing, 15)
		}
		.font(.system(size: 14))
		.background(
			RoundedRectangle(cornerRadius: 5, style: .continuous)
				.stroke(Color(.tertiaryLabel), lineWidth: 1)
		)
	}
}
