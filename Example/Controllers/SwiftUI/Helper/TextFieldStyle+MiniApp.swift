import Foundation
import SwiftUI

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
