import Foundation
import GoogleMobileAds

/// Made to be a singleton and has to be used with shared instance
/// It has to be a single instance to avoid multiple initializations of Admob SDK
internal class MiniAppAdmobDisplayer: NSObject, MiniAppAdDisplayProtocol {
	static let shared = MiniAppAdmobDisplayer()

	var interstitialAds: [String: GADInterstitial?] = [:]
	var rewardedAds: [String: GADRewardedAd?] = [:]
	var onInterstitialClosed: (() -> Void)?
	var onRewardedClosed: ((MiniAppReward?) -> Void)?
	var lastReward: MiniAppReward?

	var window: UIWindow? {
		if #available(iOS 13, *) {
			return UIApplication.shared.windows.filter { $0.isKeyWindow }.first
		} else {
			return UIApplication.shared.keyWindow
		}
	}

	override init() {
		super.init()

		GADMobileAds.sharedInstance().start(completionHandler: nil)
	}

	func loadRewarded(forId id: String) {
		rewardedAds[id] = GADRewardedAd(adUnitID: id)
		rewardedAds[id]??.load(GADRequest())
	}

	func loadInterstitial(forId id: String) {
		interstitialAds[id] = GADInterstitial(adUnitID: id)
		interstitialAds[id]??.delegate = self
		interstitialAds[id]??.load(GADRequest())
	}

	func showInterstitial(forId id: String, onClosed: @escaping (() -> Void), onFailed: @escaping ((Error) -> Void)) {
		if interstitialAds[id]??.isReady == true,
			let viewController = window?.topController() {
			onInterstitialClosed = onClosed
			interstitialAds[id]??.present(fromRootViewController: viewController)
		} else {
			onFailed(NSError())
		}
		return
	}

	func showRewarded(forId id: String, onClosed: @escaping ((MiniAppReward?) -> Void), onFailed: @escaping ((Error) -> Void)) {
		if rewardedAds[id]??.isReady == true, let viewController = window?.topController() {
			onRewardedClosed = onClosed
			rewardedAds[id]??.present(fromRootViewController: viewController, delegate: self)
		} else {
			onFailed(NSError())
		}
		return
	}
}

extension MiniAppAdmobDisplayer: GADInterstitialDelegate {
	func interstitialDidDismissScreen(_ ad: GADInterstitial) { //swiftlint:disable:this identifier_name
		self.onInterstitialClosed?()
	}
}

extension MiniAppAdmobDisplayer: GADRewardedAdDelegate {
	func rewardedAd(_ rewardedAd: GADRewardedAd, userDidEarn reward: GADAdReward) {
		lastReward = MiniAppReward(type: "undefined", amount: Int(truncating: reward.amount))
	}

	func rewardedAdDidDismiss(_ rewardedAd: GADRewardedAd) {
		self.onRewardedClosed?(self.lastReward)
	}
}
