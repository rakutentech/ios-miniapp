import Foundation

extension Date {
    var epochInMilliseconds: String {
        let currentDate = Date()
        return String(Int(currentDate.timeIntervalSince1970 * 1000))
    }

    func dateToNumber() -> Int {
        let timeSince1970 = self.timeIntervalSince1970
        return Int(timeSince1970 * 1000)
    }
}
