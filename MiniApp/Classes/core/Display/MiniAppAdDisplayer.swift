import Foundation

// Swift doesn't have load-time initialization so we need
// this proxy class that is called by LoaderObjC's `load`
// method.
public class MiniAppAdLoader: NSObject {
	@objc public static func loadMiniAds() {
		DispatchQueue.main.asyncAfter(deadline: .now()) {
			MiniAppAdDisplayer.shared.initFramework()
		}
	}
}

/// This class is the parent class meant to be overriden when implementing ads SDK
/// - Tag: MiniAppAdDisplayer
internal class MiniAppAdDisplayer: NSObject {
	#if RMA_SDK_ADMOB
	static let shared = AdMobDisplayer()
	#else
	static let shared = MiniAppAdDisplayer()
	#endif

	weak var delegate: MiniAppAdDisplayDelegate?
	var onInterstitialClosed: [String: () -> Void] = [:]
	var onRewardedClosed: [String: (MiniAppReward?) -> Void] = [:]
	var rewards: [String: MiniAppReward] = [:]

	func initFramework() {
	}

	func loadRequestedAd(forParams params: RequestParameters?) -> Bool {
		guard let delegate = delegate, let params = params, let adTypeRaw = params.adType, let adType = MiniAppAdType(rawValue: adTypeRaw), let adId = params.adUnitId else {
			return false
		}
		switch adType {
		case .interstitial:
			delegate.loadInterstitial(forId: adId)
		case .rewarded:
			delegate.loadRewarded(forId: adId)
		}
		return true
	}

	func cleanReward(_ adId: String) {
		onRewardedClosed.removeValue(forKey: adId)
		rewards.removeValue(forKey: adId)
	}

	func cleanInterstitial(_ adId: String) {
		onInterstitialClosed.removeValue(forKey: adId)
	}
}
