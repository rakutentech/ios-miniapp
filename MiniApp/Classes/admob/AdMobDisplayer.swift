import Foundation
import GoogleMobileAds

/// This subclass of [MiniAppAdDisplayer](x-source-tag://MiniAppAdDisplayer) is internally used by Mini App SDK to display Google Ads
internal class AdMobDisplayer: MiniAppAdDisplayer {
	var interstitialAds: [String: GADInterstitial] = [:]
	var rewardedAds: [String: GADRewardedAd] = [:]
	var onInterstitialLoadedError: [String: (Error) -> Void] = [:]
	var onInterstitialLoaded: [String: () -> Void] = [:]

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
		onInterstitialLoadedError.removeValue(forKey: adId)
		onInterstitialLoaded.removeValue(forKey: adId)
		interstitialAds.removeValue(forKey: adId)
		super.cleanInterstitial(adId)
	}

	private func onReadyFailCheck(ready: Bool, onFailed: @escaping (Error) -> Void, adId: String, gad: NSObject?) {
		if gad == nil {
			onFailed(NSError.miniAppAdNotLoaded(message: createNotLoadingReqError(adUnitId: adId)))
		} else if ready {
			onFailed(NSError.miniAppAdNotLoaded(message: createLoadTwiceError(adUnitId: adId)))
		} else {
			onFailed(NSError.miniAppAdNotLoaded(message: createLoadReqError(adUnitId: adId)))
		}
	}

	func createNotLoadingReqError(adUnitId: String) -> String {
		"Ad \(adUnitId) is not loading"
	}

	func createLoadReqError(adUnitId: String) -> String {
		"Previous \(adUnitId) is still in progress"
	}

	func createLoadTwiceError(adUnitId: String) -> String {
		"Ad \(adUnitId) is already loaded"
	}
}

extension AdMobDisplayer: MiniAppAdDisplayDelegate {
	func loadInterstitial(for adId: String, onLoaded: @escaping () -> Void, onFailed: @escaping (Error) -> Void) {
		if let gad = interstitialAds[adId] {
			let ready = gad.isReady
			onReadyFailCheck(ready: ready, onFailed: onFailed, adId: adId, gad: gad)
		} else {
			onInterstitialLoaded[adId] = onLoaded
			onInterstitialLoadedError[adId] = onFailed
			interstitialAds[adId] = GADInterstitial(adUnitID: adId)
			interstitialAds[adId]?.delegate = self
			interstitialAds[adId]?.load(GADRequest())
		}
	}

	func loadRewarded(for adId: String, onLoaded: @escaping () -> Void, onFailed: @escaping (Error) -> Void) {
		if let gad = rewardedAds[adId] {
			let ready = gad.isReady
			onReadyFailCheck(ready: ready, onFailed: onFailed, adId: adId, gad: gad)
		} else {
			rewardedAds[adId] = GADRewardedAd(adUnitID: adId)
			rewardedAds[adId]?.load(GADRequest()) { error in
				if let err = error {
					onFailed(err)
				} else {
					onLoaded()
				}
			}
		}
	}

	func showInterstitial(for adId: String, onClosed: @escaping () -> Void, onFailed: @escaping (Error) -> Void) {
		if interstitialAds[adId]?.isReady ?? false {
		   if let viewController = UIApplication.topViewController() {
			   onInterstitialClosed[adId] = onClosed
			   interstitialAds[adId]?.present(fromRootViewController: viewController)
		   } else {
			   onFailed(NSError.miniAppAdNotLoaded(message: "Ad cannot be displayed"))
		   }
		} else {
			onReadyFailCheck(ready: false, onFailed: onFailed, adId: adId, gad: interstitialAds[adId])
		}
	}

	func showRewarded(for adId: String, onClosed: @escaping (MiniAppReward?) -> Void, onFailed: @escaping (Error) -> Void) {
		if rewardedAds[adId]?.isReady ?? false {
			if let viewController = UIApplication.topViewController() {
				onRewardedClosed[adId] = onClosed
				rewardedAds[adId]?.present(fromRootViewController: viewController, delegate: self)
			} else {
				onFailed(NSError.miniAppAdNotLoaded(message: "Ad cannot be displayed"))
			}
		} else {
			onReadyFailCheck(ready: false, onFailed: onFailed, adId: adId, gad: rewardedAds[adId])
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

	/// Called when an interstitial ad request succeeded. Show it at the next transition point in your
	/// application such as when transitioning between view controllers.
	func interstitialDidReceiveAd(_ ad: GADInterstitial) { // swiftlint:disable:this identifier_name
		if let id = ad.adUnitID {
			onInterstitialLoaded[id]?()
		}
	}

	/// Called when an interstitial ad request completed without an interstitial to
	/// show. This is common since interstitials are shown sparingly to users.
	func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError) { // swiftlint:disable:this identifier_name
		if let id = ad.adUnitID {
			onInterstitialLoadedError[id]?(error)
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
