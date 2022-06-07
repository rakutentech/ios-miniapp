import Foundation

public class MAPoints: Codable {
    let standard: Int
    let term: Int
    let cash: Int

    public init(standard: Int, term: Int, cash: Int) {
        self.standard = standard
        self.term = term
        self.cash = cash
    }
}
