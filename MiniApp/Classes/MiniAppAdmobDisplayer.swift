import Foundation
import GoogleMobileAds

/// Made to be a singleton
/// It has to be a single instance to avoid multiple instances of Admob SDK
class MiniAppAdmobDisplayer: NSObject, MiniAppAdDisplayProtocol {
	var interstitial: GADInterstitial!
	var rewarded: GADRewardedAd?
	var onInterstitialClosed: (() -> Void)?
	var onRewardedClosed: ((MiniAppReward?) -> Void)?
	var lastReward: MiniAppReward?

	override init() {
		super.init()

		GADMobileAds.sharedInstance().start(completionHandler: { [weak self] _ in
			self?.createAndLoadInterstitial()
			self?.createAndLoadRewarded()
		})

	}

	private func createAndLoadRewarded() {
		//TEST: Google's test id from tutorial
		rewarded = GADRewardedAd(adUnitID: "ca-app-pub-3940256099942544/1712485313")
		rewarded?.load(GADRequest())
	}

	private func createAndLoadInterstitial() {
		//TEST: Google's test id from tutorial
		interstitial = GADInterstitial(adUnitID: "ca-app-pub-3940256099942544/4411468910")
		interstitial.delegate = self
		interstitial.load(GADRequest())
	}

	func showInterstitial(onClosed: @escaping (() -> Void), onFailed: @escaping ((Error) -> Void)) {
		if interstitial.isReady {
			onInterstitialClosed = onClosed
			let window: UIWindow?
			if #available(iOS 13, *) {
				window = UIApplication.shared.windows.filter { $0.isKeyWindow }.first
			} else {
				window = UIApplication.shared.keyWindow
			}
			if let viewController = window?.topController() {
				interstitial.present(fromRootViewController: viewController)
			}
		} else {
			onFailed(NSError())
		}
		return
	}

	func showRewarded(onClosed: @escaping ((MiniAppReward?) -> Void), onFailed: @escaping ((Error) -> Void)) {
		if rewarded?.isReady == true {
			onRewardedClosed = onClosed
			let window: UIWindow?
			if #available(iOS 13, *) {
				window = UIApplication.shared.windows.filter { $0.isKeyWindow }.first
			} else {
				window = UIApplication.shared.keyWindow
			}
			if let viewController = window?.topController() {
				rewarded?.present(fromRootViewController: viewController, delegate: self)
			}
		} else {
			onFailed(NSError())
		}
		return
	}
}

extension MiniAppAdmobDisplayer: GADInterstitialDelegate {
	func interstitialDidDismissScreen(_ ad: GADInterstitial) { //swiftlint:disable:this identifier_name
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
