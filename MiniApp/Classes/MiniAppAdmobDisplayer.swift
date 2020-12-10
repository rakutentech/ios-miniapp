import Foundation
import GoogleMobileAds

/// Made to be a singleton and has to be used with shared instance
/// It has to be a single instance to avoid multiple initializations of Admob SDK
internal class MiniAppAdmobDisplayer: NSObject, MiniAppAdDisplayDelegate {
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

	func loadRequestedAd(forParams params: RequestParameters?) -> Bool {
		//PIERRE: params.adUnitId here is always nil
		// adType works fine 0 for interstitial and 1 for rewarded are showing up properly
		// only adUnitId is nil. Something wrong with the bridge.js script ?
		guard let params = params, let adTypeRaw = params.adType, let adType = MiniAppAdType(rawValue: adTypeRaw), let adId = params.adUnitId else {
			return false
		}
		switch adType {
		case .interstitial:
			loadInterstitial(forId: adId)
		case .rewarded:
			loadRewarded(forId: adId)
		}
		return true
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
	// function predicate comes from Google's SDK, had to disable swiftlint rule
	func interstitialDidDismissScreen(_ ad: GADInterstitial) { //swiftlint:disable:this identifier_name
		if let id = ad.adUnitID {
			interstitialAds[id] = nil
		}
		self.onInterstitialClosed?()
	}
}

extension MiniAppAdmobDisplayer: GADRewardedAdDelegate {
	func rewardedAd(_ rewardedAd: GADRewardedAd, userDidEarn reward: GADAdReward) {
		//PIERRE: How to define reward type here ?
		lastReward = MiniAppReward(type: "", amount: Int(truncating: reward.amount))
	}

	func rewardedAdDidDismiss(_ rewardedAd: GADRewardedAd) {
		rewardedAds[rewardedAd.adUnitID] = nil
		self.onRewardedClosed?(self.lastReward)
	}
}
