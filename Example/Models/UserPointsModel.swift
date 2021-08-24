import Foundation

struct UserPointsModel: Codable {
    var standardPoints: Int?
    var termPoints: Int?
    var cashPoints: Int?

    static let LocalCacheKey = "UserPoints"
}

func getUserPoints(key: String = UserPointsModel.LocalCacheKey) -> UserPointsModel? {
    if let userPointsData = UserDefaults.standard.data(forKey: key) {
        let userPoints = try? PropertyListDecoder().decode(UserPointsModel.self, from: userPointsData)
        return userPoints
    }
    return nil
}

func saveUserPoints(
    forKey key: String = UserPointsModel.LocalCacheKey,
    pointsModel: UserPointsModel
) -> Bool {
    if let data = try? PropertyListEncoder().encode(pointsModel) {
        UserDefaults.standard.set(data, forKey: key)
        return UserDefaults.standard.synchronize()
    }
    return false
}
