extension Date {
    var currentDate: String {
        let currentDate = Date()
        return String(Int(currentDate.timeIntervalSince1970 * 1000))
    }
}
