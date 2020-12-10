import Foundation

public protocol MiniAppAdDisplayProtocol {
	// Interstitial ads related
	func loadInterstitial(forId: String)
	func showInterstitial(forId: String, onClosed: @escaping (() -> Void), onFailed: @escaping ((Error) -> Void))

	// Rewarded ads related
	func loadRewarded(forId: String)
	func showRewarded(forId: String, onClosed: @escaping ((MiniAppReward?) -> Void), onFailed: @escaping ((Error) -> Void))
}
