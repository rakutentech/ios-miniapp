import Foundation
import GoogleMobileAds

/// This subclass of [MiniAppAdDisplayer](x-source-tag://MiniAppAdDisplayer) is internally used by Mini App SDK to display Google Ads
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

	override func cleanReward(_ adId: String) {
		rewardedAds.removeValue(forKey: adId)
		super.cleanReward(adId)
	}

	override func cleanInterstitial(_ adId: String) {
		interstitialAds.removeValue(forKey: adId)
		super.cleanInterstitial(adId)
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

	func showInterstitial(forId id: String, onClosed: @escaping () -> Void, onFailed: @escaping (Error) -> Void) {
		if interstitialAds[id]??.isReady == true,
		   let viewController = UIApplication.topViewController() {
			onInterstitialClosed[id] = onClosed
			interstitialAds[id]??.present(fromRootViewController: viewController)
		} else {
			onFailed(NSError())
		}
	}

	func showRewarded(forId id: String, onClosed: @escaping (MiniAppReward?) -> Void, onFailed: @escaping (Error) -> Void) {
		if rewardedAds[id]??.isReady == true, let viewController = UIApplication.topViewController() {
			onRewardedClosed[id] = onClosed
			rewardedAds[id]??.present(fromRootViewController: viewController, delegate: self)
		} else {
			onFailed(NSError())
		}
	}
}

extension AdMobDisplayer: GADInterstitialDelegate {
	// function predicate comes from Google's SDK, had to disable swiftlint rule
	func interstitialDidDismissScreen(_ ad: GADInterstitial) { // swiftlint:disable:this identifier_name
		if let id = ad.adUnitID {
			onInterstitialClosed[id]?()
			cleanInterstitial(id)
		}

	}
}

extension AdMobDisplayer: GADRewardedAdDelegate {
	func rewardedAd(_ rewardedAd: GADRewardedAd, userDidEarn reward: GADAdReward) {
		rewards[rewardedAd.adUnitID] = MiniAppReward(type: reward.type, amount: Int(truncating: reward.amount))
	}

	func rewardedAdDidDismiss(_ rewardedAd: GADRewardedAd) {
		onRewardedClosed[rewardedAd.adUnitID]?(rewards[rewardedAd.adUnitID])
		cleanReward(rewardedAd.adUnitID)
	}
}
