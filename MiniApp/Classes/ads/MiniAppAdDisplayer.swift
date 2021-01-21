import Foundation
import GoogleMobileAds

// Swift doesn't have load-time initialization so we need
// this proxy class that is called by LoaderObjC's `load`
// method.
public class MiniAppAdLoader: NSObject {
	@objc public static func loadMiniAds() {
		DispatchQueue.main.asyncAfter(deadline: .now()) {
			GADMobileAds.sharedInstance().start(completionHandler: nil)
		}
	}
}

/// Made to be a singleton and has to be used with shared instance
/// It has to be a single instance to avoid multiple initializations of Admob SDK
internal class MiniAppAdDisplayer: NSObject, MiniAppAdDisplayDelegate {
	static let shared = MiniAppAdDisplayer()

	var interstitialAds: [String: GADInterstitial?] = [:]
	var rewardedAds: [String: GADRewardedAd?] = [:]
	var onInterstitialClosed: (() -> Void)?
	var onRewardedClosed: ((MiniAppReward?) -> Void)?
	var rewards: [String: MiniAppReward] = [:]

	var window: UIWindow? {
		if #available(iOS 13, *) {
			return UIApplication.shared.windows.filter { $0.isKeyWindow }.first
		} else {
			return UIApplication.shared.keyWindow
		}
	}

	func loadRequestedAd(forParams params: RequestParameters?) -> Bool {
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

extension MiniAppAdDisplayer: GADInterstitialDelegate {
	// function predicate comes from Google's SDK, had to disable swiftlint rule
	func interstitialDidDismissScreen(_ ad: GADInterstitial) { //swiftlint:disable:this identifier_name
		if let id = ad.adUnitID {
			interstitialAds[id] = nil
		}
		self.onInterstitialClosed?()
	}
}

extension MiniAppAdDisplayer: GADRewardedAdDelegate {
	func rewardedAd(_ rewardedAd: GADRewardedAd, userDidEarn reward: GADAdReward) {
		rewards[rewardedAd.adUnitID] = MiniAppReward(type: reward.type, amount: Int(truncating: reward.amount))
	}

	func rewardedAdDidDismiss(_ rewardedAd: GADRewardedAd) {
		rewardedAds[rewardedAd.adUnitID] = nil
		self.onRewardedClosed?(self.rewards[rewardedAd.adUnitID])
	}
}
