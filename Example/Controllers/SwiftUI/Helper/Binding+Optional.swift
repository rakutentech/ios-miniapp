import Foundation
import SwiftUI

// swiftlint:disable operator_whitespace syntactic_sugar

func ??<T>(lhs: Binding<Optional<T>>, rhs: T) -> Binding<T> {
    Binding(
        get: { lhs.wrappedValue ?? rhs },
        set: { lhs.wrappedValue = $0 }
    )
}
// swiftlint:enable operator_whitespace syntactic_sugar
