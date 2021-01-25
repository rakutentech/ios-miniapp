import Foundation

/// A MiniAppReward is the structure that is returned to the Mini App when a rewarded ad is displayed to an user
/// The host app developer can provide a reward type and the amount earned for watching the ad
/// - Tag: MiniAppReward
public struct MiniAppReward: Codable {
	let type: String
	let amount: Int
}
