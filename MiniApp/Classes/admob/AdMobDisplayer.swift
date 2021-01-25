import Foundation
import GoogleMobileAds

/// Made to be a singleton and has to be used with shared instance
/// It has to be a single instance to avoid multiple initializations of Admob SDK
internal class AdMobDisplayer: MiniAppAdDisplayer {
	var interstitialAds: [String: GADInterstitial?] = [:]
	var rewardedAds: [String: GADRewardedAd?] = [:]

	override init() {
		super.init()
		delegate = self
	}

	override func initFramework() {
		GADMobileAds.sharedInstance().start(completionHandler: nil)
	}
}

extension AdMobDisplayer: MiniAppAdDisplayDelegate {
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
		   let viewController = UIApplication.topViewController() {
			onInterstitialClosed = onClosed
			interstitialAds[id]??.present(fromRootViewController: viewController)
		} else {
			onFailed(NSError())
		}
		return
	}

	func showRewarded(forId id: String, onClosed: @escaping ((MiniAppReward?) -> Void), onFailed: @escaping ((Error) -> Void)) {
		if rewardedAds[id]??.isReady == true, let viewController = UIApplication.topViewController() {
			onRewardedClosed = onClosed
			rewardedAds[id]??.present(fromRootViewController: viewController, delegate: self)
		} else {
			onFailed(NSError())
		}
		return
	}
}

extension AdMobDisplayer: GADInterstitialDelegate {
	// function predicate comes from Google's SDK, had to disable swiftlint rule
	func interstitialDidDismissScreen(_ ad: GADInterstitial) { // swiftlint:disable:this identifier_name
		if let id = ad.adUnitID {
			interstitialAds[id] = nil
		}
		self.onInterstitialClosed?()
	}
}

extension AdMobDisplayer: GADRewardedAdDelegate {
	func rewardedAd(_ rewardedAd: GADRewardedAd, userDidEarn reward: GADAdReward) {
		rewards[rewardedAd.adUnitID] = MiniAppReward(type: reward.type, amount: Int(truncating: reward.amount))
	}

	func rewardedAdDidDismiss(_ rewardedAd: GADRewardedAd) {
		rewardedAds[rewardedAd.adUnitID] = nil
		self.onRewardedClosed?(self.rewards[rewardedAd.adUnitID])
	}
}
