import Foundation

internal extension Int {
    func compare(to anotherInt: Self) -> Int {
        if self != anotherInt {
            if self > anotherInt {
                return 1
            } else {
                return -1
            }
        }
        return 0
    }
}
