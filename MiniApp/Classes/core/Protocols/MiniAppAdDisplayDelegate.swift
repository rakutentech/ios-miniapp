import Foundation

public protocol MiniAppAdDisplayDelegate: class {
	/// Load Interstitial ad
	/// This function preloads Interstitial ad before they are requested for display.
	/// Can be called multiple times to pre-load multiple ads.
	func loadInterstitial(for adId: String, onLoaded: @escaping () -> Void, onFailed: @escaping (Error) -> Void)

	/// Show a pre-loaded Interstitial ad
	func showInterstitial(for adId: String, onClosed: @escaping () -> Void, onFailed: @escaping (Error) -> Void)

	/// Load Rewarded ad
	/// This function preloads Interstitial ad before they are requested for display.
	/// Can be called multiple times to pre-load multiple ads.
	func loadRewarded(for adId: String, onLoaded: @escaping () -> Void, onFailed: @escaping (Error) -> Void)

	/// Show a pre-loaded Rewarded ad
	func showRewarded(for adId: String, onClosed: @escaping (MiniAppReward?) -> Void, onFailed: @escaping (Error) -> Void)
}
