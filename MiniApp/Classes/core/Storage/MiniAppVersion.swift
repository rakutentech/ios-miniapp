import Foundation

internal struct MiniAppVersion {
    let major: Int?
    let minor: Int?
    let hotfix: Int?
    let environment: String?

    init?(string: String?) {
        MiniAppLogger.d("version to extract: \(string ?? "nil")")
        guard let string = string else {
            return nil
        }

        var version = string.components(separatedBy: ".")

        guard let majorString = version.first else {
            minor = nil
            hotfix = nil
            environment = nil
            major = nil
            return
        }
        major = Int(majorString)
        guard major != nil, version.count > 1 else {
            minor = nil
            hotfix = nil
            environment = nil
            return
        }
        minor = Int(version[1])
        guard minor != nil, version.count > 2 else {
            hotfix = nil
            environment = nil
            return
        }

        guard let fixNumber = Int(version[2]), version.count > 3 else {
            let hotfixExtractionAttempt = version[2].components(separatedBy: CharacterSet(charactersIn: "- "))
            if hotfixExtractionAttempt.count > 0 {
                hotfix = Int(hotfixExtractionAttempt[0])
                if hotfixExtractionAttempt.count > 1 {
                    environment = version[2].replacingOccurrences(of: hotfixExtractionAttempt[0], with: "")
                } else {
                    environment = nil
                }
            } else {
                hotfix = nil
                environment = nil
            }
            return
        }
        hotfix = fixNumber
        version.removeSubrange(0..<3)
        environment = version.joined(separator: ".")
    }
}

extension MiniAppVersion: CustomStringConvertible {
    var description: String {
        "\(major ?? 0).\(minor ?? 0).\(hotfix ?? 0)\(environment ?? "")"
    }
}

extension MiniAppVersion: Comparable {
    static func < (lhs: MiniAppVersion, rhs: MiniAppVersion) -> Bool {
        lhs.compare(rhs) ?? 0 < 0
    }
    static func > (lhs: MiniAppVersion, rhs: MiniAppVersion) -> Bool {
        lhs.compare(rhs) ?? 0 > 0
    }
    static func == (lhs: MiniAppVersion, rhs: MiniAppVersion) -> Bool {
        lhs.compare(rhs) ?? -1 == 0
    }

    /// This method compares 2 x.y.z version numbers between them
    ///
    /// - Parameters:
    ///   - secondVersion: The version number to compare to the first one
    ///   - checkEnvironment: A boolean to decide if everything after hotfix number should be compared
    /// - Returns: 0 if they are identical, -1 if secondVersion is higher, 1 if first version is higher and nil if they can't be compared
    public func compare(_ secondVersion: MiniAppVersion, checkEnvironment: Bool = false) -> Int? {
        if checkEnvironment, environment != secondVersion.environment {
            return nil
        }
        var result: Int?

        if let major1 = major,
           let major2 = secondVersion.major {
            result = major1.compare(to: major2)
        }
        if result == 0,
           let minor1 = minor,
           let minor2 = secondVersion.minor {
            result = minor1.compare(to: minor2)
        }
        if result == 0,
           let fix1 = hotfix,
           let fix2 = secondVersion.hotfix {
            result = fix1.compare(to: fix2)
        }
        MiniAppLogger.d("\(self)>\(secondVersion)=\(result ?? 999)")
        return result
    }
}
