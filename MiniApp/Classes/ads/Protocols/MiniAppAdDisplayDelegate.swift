import Foundation

public protocol MiniAppAdDisplayDelegate {
	/// Load Interstitial ad
	/// This function preloads Interstitial ad before they are requested for display.
	/// Can be called multiple times to pre-load multiple ads.
	func loadInterstitial(forId: String)

	/// Show a pre-loaded Interstitial ad
	func showInterstitial(forId: String, onClosed: @escaping (() -> Void), onFailed: @escaping ((Error) -> Void))

	/// Load Rewarded ad
	/// This function preloads Interstitial ad before they are requested for display.
	/// Can be called multiple times to pre-load multiple ads.
	func loadRewarded(forId: String)

	/// Show a pre-loaded Rewarded ad
	func showRewarded(forId: String, onClosed: @escaping ((MiniAppReward?) -> Void), onFailed: @escaping ((Error) -> Void))
}
