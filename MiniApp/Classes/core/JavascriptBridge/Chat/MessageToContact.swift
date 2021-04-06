import Foundation

public class MessageToContact: Codable, Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(image)
        hasher.combine(text)
        hasher.combine(caption)
        hasher.combine(action)
        hasher.combine(title)
    }

    public static func ==(lhs: MessageToContact, rhs: MessageToContact) -> Bool {
        lhs.hashValue == rhs.hashValue
    }

    public let image: String
    public let text: String
    public let caption: String
    public let action: String
    public let title: String
}
