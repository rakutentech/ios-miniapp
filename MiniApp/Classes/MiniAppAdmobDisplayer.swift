import Foundation
import GoogleMobileAds

/// Made to be a singleton
/// It has to be a single instance to avoid multiple instances of Admob SDK
class MiniAppAdmobDisplayer: NSObject, MiniAppAdDisplayProtocol {
	var isAdmobInitialized = false
	var interstitial: GADInterstitial!
	var rewarded: GADRewardedAd?
	var onInterstitialClosed: (() -> Void)?
	var onRewardedClosed: ((MiniAppReward?) -> Void)?
	var lastReward: MiniAppReward?

	override init() {
		super.init()

		createAndLoadInterstitial()
		createAndLoadRewarded()
	}

	private func createAndLoadRewarded() {
		rewarded = GADRewardedAd(adUnitID: "ca-app-pub-3940256099942544/1712485313")
		rewarded?.load(GADRequest())
	}

	private func createAndLoadInterstitial() {
		interstitial = GADInterstitial(adUnitID: "ca-app-pub-3940256099942544/4411468910")
		interstitial.delegate = self
		interstitial.load(GADRequest())
	}

	func showInterstitial(onClosed: @escaping (() -> Void), onFailed: @escaping ((Error) -> Void)) {
		if !isAdmobInitialized {
			GADMobileAds.sharedInstance().start(completionHandler: {
				[weak self] _ in

				self?.isAdmobInitialized = true
				self?.showInterstitial(onClosed: onClosed, onFailed: onFailed)
			})
		} else if interstitial.isReady {
			self.onInterstitialClosed = onClosed
			// PIERRE: here I need some reference to the viewController displaying the miniApp to allow the `present`
			interstitial.present(fromRootViewController: UIViewController())
		} else {
			onFailed(NSError())
		}
		return
	}

	func showRewarded(onClosed: @escaping ((MiniAppReward?) -> Void), onFailed: @escaping ((Error) -> Void)) {
		if !isAdmobInitialized {
			GADMobileAds.sharedInstance().start(completionHandler: {
				[weak self] _ in

				self?.isAdmobInitialized = true
				self?.showRewarded(onClosed: onClosed, onFailed: onFailed)
			})
		} else if rewarded?.isReady == true {
			onRewardedClosed = onClosed
			// PIERRE: here I need some reference to the viewController displaying the miniApp to allow the `present`
			rewarded?.present(fromRootViewController: UIViewController(), delegate: self)
		} else {
			onFailed(NSError())
		}
		return
	}
}

extension MiniAppAdmobDisplayer: GADInterstitialDelegate {
	func interstitialDidDismissScreen(_ ad: GADInterstitial) {
		createAndLoadInterstitial()
		self.onInterstitialClosed?()
	}
}

extension MiniAppAdmobDisplayer: GADRewardedAdDelegate {
	func rewardedAd(_ rewardedAd: GADRewardedAd, userDidEarn reward: GADAdReward) {
		lastReward = MiniAppReward(type: "undefined", amount: Int(truncating: reward.amount))
	}

	func rewardedAdDidDismiss(_ rewardedAd: GADRewardedAd) {
		createAndLoadRewarded()
		self.onRewardedClosed?(self.lastReward)
	}
}
