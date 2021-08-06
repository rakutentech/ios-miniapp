import Foundation

public protocol MiniAppAdDisplayDelegate: AnyObject {

	/// Load Interstitial ad
	/// This function preloads Interstitial ad before they are requested for display.
	/// Can be called multiple times to pre-load multiple ads.
	func loadInterstitial(for adId: String, onLoaded: @escaping (Result<Void, Error>) -> Void)

	/// Show a pre-loaded Interstitial ad
	func showInterstitial(for adId: String, onClosed: @escaping (Result<Void, Error>) -> Void)

	/// Load Rewarded ad
	/// This function preloads Interstitial ad before they are requested for display.
	/// Can be called multiple times to pre-load multiple ads.
	func loadRewarded(for adId: String, onLoaded: @escaping (Result<Void, Error>) -> Void)

	/// Show a pre-loaded Rewarded ad
	func showRewarded(for adId: String, onClosed: @escaping (Result<MiniAppReward, Error>) -> Void)
}

/// Enumeration that is used to differentiate the Custom permission errors
public enum MASDKAdsDisplayError: String, MiniAppErrorProtocol {

	/// Unknown Error
	case unknownError = "UKNOWN_ERROR"

	/// Host app failed to implement required interface
	case failedToConformToProtocol = "FAILED_TO_CONFORM_PROTOCOL"

	/// Third party ads SDK failed to load
	case sdkError

	/// Ad is not ready to be displayed
	case adNotLoaded

	/// Ad identifiers not provided or wrong request parameters format
	case adIdError

	/// Failed to get a reward from ad displaying
	case rewardFailure

	/// The host controller is not able to display the ad
	case hostUIError

	var name: String {
		self.rawValue
	}

	/// Detailed Description for every MASDKAdsDisplayError
	public var description: String {
		switch self {
		case .unknownError:
			return "Unknown error occurred"
		case .failedToConformToProtocol:
			return "Host app failed to implement required interface"
		case .sdkError:
			return "Third party Ads SDK failed to provide an ad"
		case .adNotLoaded:
			return "Ad is not ready to launch"
		case .rewardFailure:
			return "A reward could not be generated"
		case .hostUIError:
			return "The host controller is not able to display the ad"
		case .adIdError:
			return "Ad identifiers not provided or wrong request parameters format"
		}
	}
}
