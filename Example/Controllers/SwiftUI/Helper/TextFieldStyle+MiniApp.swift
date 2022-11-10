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

struct NumberPadKeyboardViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 15.0, *) {
            content
            .keyboardType(.numberPad)
            .toolbar {
                ToolbarItem(placement: .keyboard) {
                    HStack {
                        Spacer()
                        Button("Done") {
                            dismissKeyboard()
                        }
                        .foregroundColor(.blue)
                    }
                }
            }
        } else {
            // keep default layout for iOS 14 to dismiss the keyboard
            // can be removed after min target upgrade to iOS 15
            content
        }
    }

    func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

extension View {
    func keyboardWithCustomNumberPad() -> some View {
        modifier(NumberPadKeyboardViewModifier())
    }

    func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
